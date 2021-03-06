classdef Est_DirectDynamicModel
    % Implementation of the Dynamic Model based estimation
    properties
        para % estimation parameters
        mode % estimation mode 
        uf % Frame transformation utility
        ur % Russell data utility
        uad % Airdensity utility  
    end
    
    methods
        function obj = Est_DirectDynamicModel(para, mode)
            % Constructor. Initializes utilities.
            % INPUT : 
            %   para : parameter set as a structure
            % OUTPUT : 
            %   obj : constructed object
            obj.para = para;
            obj.mode = mode;
            obj.uf = Util_Frame();
            obj.ur = Util_Russell();
            obj.uad = Util_AirDensity();
        end
        
        function ttDragNED = computeDrag(obj, data, rho)
            % Computes drag forces
            % INPUT :
            %   data : timetable as outputed by preprocessing
            %   rho : air density [kg/m^3]
            % OUTPUT :
            %   ttDragNED : timetable containing drag estimate in NED frame. Time vector is the same as in data.
            %               (thrust and acceleration in NED are also present for debugging)
            thrust = obj.ur.getHoverThrust(0.5*vecnorm([data.motRpm_RF, data.motRpm_LF, data.motRpm_LB, data.motRpm_RB],2,2), rho);
            thrustNED = obj.uf.XYZ2NED([zeros(size(thrust,1),2), -thrust], data.q1, data.q2, data.q3, data.q4);
            
            aNED = obj.uf.XYZ2NED([data.ax, data.ay, data.az], data.q1, data.q2, data.q3, data.q4);

            dragNED = aNED.*obj.para.cst.m - thrustNED;
            ttDragNED = timetable(dragNED, thrustNED, aNED, 'RowTimes', data.Time);
        end

        function ttDragNED = computeDragNoVert(obj, data)
            % TODO : comment
            fb = [data.ax, data.ay, data.az];
            Cbl = rotmat(quaternion(data.q1, data.q2, data.q3, data.q4), 'point');

            dragNED = zeros(size(data,1),3);
            thrustXYZ = zeros(size(data,1),3);

            for i = 1:size(data,1)
                A = [1 0 Cbl(1,3,i); 0 1 Cbl(2,3,i); 0 0 Cbl(3,3,i)];
                b = obj.para.cst.m*Cbl(:,:,i)*fb(i,:)';
                x = A\b;
                dragNED(i,1:2) = x(1:2);
                thrustXYZ(i,3) = x(3);
            end

            thrustNED = obj.uf.XYZ2NED(thrustXYZ, data.q1, data.q2, data.q3, data.q4);

            ttDragNED = timetable(dragNED, thrustNED, 'RowTimes', data.Time);
        end

        function ttWind = computeWind(obj, data, ttDragNED, rho, verticalDrag, model)
            % Computes wind estimation 
            % INPUT : 
            %   data : timetable as outputed by preprocessing
            %   ttDragNED : timetable with same time vector as data and containing a "dragNED" column
            %   rho : air density [kg/m^3]
            %   verticalDrag : boolean indicating whether vertical was computed (true) or is set to zero (false)
            %   model : drag model to be used, can be either "linear" or "quadratic"
            % OUTPUT :
            %   ttWind : timetable containing wind estimate (windHDir_est, windHMag_est, windVert_est).
            %            Time vector is the same as in data. (ws, dragTilt, asTxTz, asTy are also present for debugging).
            
            % Transform to Tilt frame
            dragTilt = obj.uf.NED2Tilt(ttDragNED.dragNED, data.q1, data.q2, data.q3, data.q4);

            % Compute ws in the [Tx, Tz] plane
            dragMagTxTz = vecnorm([dragTilt(:,1), dragTilt(:,3)],2,2);
            dragAngleTxTz = atan2(dragTilt(:,3), dragTilt(:,1));
            RPM = 0.5*vecnorm([data.motRpm_RF, data.motRpm_LF, data.motRpm_LB, data.motRpm_RB],2,2);
            asTxTz = obj.ur.getTrueAirSpeed(pi - dragAngleTxTz, RPM, dragMagTxTz, rho, model);

            % Compute ws along [Ty]
            asTy = sign(dragTilt(:,2)).*obj.ur.getTrueAirSpeed(zeros(size(RPM)), RPM, abs(dragTilt(:,2)), rho, model);

            % Transform back to NED frame
            asNED = obj.uf.Tilt2NED([asTxTz.*cos(dragAngleTxTz), asTy, asTxTz.*sin(dragAngleTxTz)], data.q1, data.q2, data.q3, data.q4);

            % Compute wind 
            if verticalDrag
                ws = obj.uf.getWindSpeed(asNED, [data.vn, data.ve, data.vd]);
            else
                ws = obj.uf.getWindSpeed(asNED, [data.vn, data.ve, zeros(size(data.vd))]);
            end
            
            [windHDir_est, windHMag_est, windVert_est] = obj.uf.getHWind(ws);
            ttWind = timetable(windHDir_est, windHMag_est, windVert_est, ws, dragTilt, asTxTz, asTy, 'RowTimes', ttDragNED.Time);
        end
        
        function tt = estimateWind(obj, data)
            % Performes wind estimate
            % INPUT :
            %   data : timetable of data as outputed by the preprocessing
            % OUTPUT :
            %   dir : timetable containing the input data as well as the 
            %         wind speed and direction estimation (windHMag_est, windHDir_est, wdinVert_est) (and some debugging data)
            if any(ismember("tempRef", data.Properties.VariableNames)) ...
                    && any(ismember("pressRef", data.Properties.VariableNames)) ...
                    && any(ismember("humidRef", data.Properties.VariableNames))
                rho = obj.uad.getAirDensity(data.tempRef, data.pressRef, data.humidRef);
            else
                rho = 1.221*ones(size(data,1),1);
                warning("[Est_DirectDynamicModel] Using default air density of " + num2str(rho(1)))
            end

            if obj.mode == "linear,vertDrag"
                drag = obj.computeDrag(data, rho);
                wind = obj.computeWind(data, drag, rho, true, "linear");
            elseif obj.mode == "linear,noVertDrag"
                drag = obj.computeDragNoVert(data);
                wind = obj.computeWind(data, drag, rho, false, "linear");
            elseif obj.mode == "quadratic,vertDrag"
                drag = obj.computeDrag(data, rho);
                wind = obj.computeWind(data, drag, rho, true, "quadratic");
            elseif obj.mode == "quadratic,noVertDrag"
                drag = obj.computeDragNoVert(data);
                wind = obj.computeWind(data, drag, rho, false, "quadratic");            
            else
                error("[Est_DirectDynamicModel] Unkown mode : " + obj.mode);
            end

            rhoTT = timetable(rho, 'RowTimes', data.Time);
            tt = synchronize(wind, data, drag, rhoTT);
        end
    end
end
