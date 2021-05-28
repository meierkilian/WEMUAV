classdef Est_DirectDynamicModel
    properties
        para
        uf % Frame transformation utility
        ur % Russell data utility
        uad % Airdensity utility  
    end
    
    methods
        % Constructor. Initializes utilities.
        % INPUT : 
        %   para : parameter set as a structure
        % OUTPUT : 
        %   obj : constructed object
        function obj = Est_DirectDynamicModel(para)
            obj.para = para;
            obj.uf = Util_Frame();
            obj.ur = Util_Russell();
            obj.uad = Util_AirDensity();
        end
        
        % Computes drag forces
        % INPUT :
        %   data : timetable as outputed by preprocessing
        %   rho : air density [kg/m^3]
        % OUTPUT :
        %   ttDragNED : timetable containing drag estimate in NED frame. Time vector is the same as in data.
        %               (thrust and acceleration in NED are also present for debugging)
        function ttDragNED = computeDrag(obj, data, rho)
            thrust = obj.ur.getHoverThrust(0.5*vecnorm([data.motRpm_RF, data.motRpm_LF, data.motRpm_LB, data.motRpm_RB],2,2), rho);
            thrustNED = obj.uf.XYZ2NED([zeros(size(thrust,1),2), -thrust], data.q1, data.q2, data.q3, data.q4);
            
            aNED = obj.uf.XYZ2NED([data.ax, data.ay, data.az], data.q1, data.q2, data.q3, data.q4);

            dragNED = thrustNED - aNED .* obj.para.cst.m;
            ttDragNED = timetable(dragNED, thrustNED, aNED, 'RowTimes', data.Time);
        end

        % Computes wind estimation 
        % INPUT : 
        %   data : timetable as outputed by preprocessing
        %   ttDragNED : timetable with same time vector as data and containing a "dragNED" column
        %   rho : air density [kg/m^3]
        % OUTPUT :
        %   ttWind : timetable containing wind estimate (windHDir_est, windHMag_est, windVert_est).
        %            Time vector is the same as in data. (ws, dragTilt, tasTxTz, tasTy are also present for debugging).
        function ttWind = computeWind(obj, data, ttDragNED, rho)
            % Transform to Tilt frame
            dragTilt = obj.uf.NED2Tilt(ttDragNED.dragNED, data.q1, data.q2, data.q3, data.q4);

            % Compute ws in the [Tx, Tz] plane
            dragMagTxTz = vecnorm([dragTilt(:,1), dragTilt(:,3)],2,2);
            dragAngleTxTz = atan2(dragTilt(:,3), dragTilt(:,1));
            [alpha, ~] = obj.uf.computeTilt(data.q1, data.q2, data.q3, data.q4);
            RPM = 0.5*vecnorm([data.motRpm_RF, data.motRpm_LF, data.motRpm_LB, data.motRpm_RB],2,2);
            tasTxTz = obj.ur.getTrueAirSpeed(alpha-dragAngleTxTz, RPM, dragMagTxTz, rho);

            % Compute ws along [Ty]
            tasTy = sign(dragTilt(:,2)).*obj.ur.getTrueAirSpeed(zeros(size(RPM)), RPM, abs(dragTilt(:,2)), rho);

            % Transform back to NED frame
            tasNED = obj.uf.Tilt2NED([tasTxTz.*cos(dragAngleTxTz), tasTy, tasTxTz.*sin(dragAngleTxTz)], data.q1, data.q2, data.q3, data.q4);

            % Compute wind 
            ws = obj.uf.getWindSpeed(tasNED, [data.vn, data.ve, data.vd]);
            [windHDir_est, windHMag_est, windVert_est] = obj.uf.getHWind(ws);
            ttWind = timetable(windHDir_est, windHMag_est, windVert_est, ws, dragTilt, tasTxTz, tasTy, 'RowTimes', ttDragNED.Time);
        end
        
        % Performes wind estimate
        % Performs wind estimation
        % INPUT :
        %   data : timetable of data as outputed by the preprocessing
        % OUTPUT :
        %   dir : timetable containing the input data as well as the 
        %         wind speed and direction estimation (windHMag_est, windHDir_est, wdinVert_est) (and some debugging data)
        function tt = estimateWind(obj, data)
            if any(ismember("tempMotus", data.Properties.VariableNames)) ...
                    && any(ismember("pressRef", data.Properties.VariableNames)) ...
                    && any(ismember("humidRef", data.Properties.VariableNames))
                rho = obj.uad.getAirDensity(mean(data.tempMotus), mean(data.pressRef), mean(data.humidRef));
            else
                rho = 1.221;
            end
            drag = obj.computeDrag(data, rho);
            wind = obj.computeWind(data, drag, rho);
            tt = synchronize(wind, data, drag);
        end
    end
end
