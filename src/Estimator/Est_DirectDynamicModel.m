classdef Est_DirectDynamicModel
    properties
        para
        uf % Frame transformation utility
        ur % Russell data utility 
    end
    
    methods
        function obj = Est_DirectDynamicModel(para)
            obj.para = para;
            obj.uf = Util_Frame();
            obj.ur = Util_Russell();
        end
        
        function ttDragNED = computeDrag(obj, data)
            % thrustMot = 0.93*obj.ur.getMotorThrust([data.motRpm_RF, data.motRpm_LF, data.motRpm_LB, data.motRpm_RB]);
            thrust = 1.2/1.22*obj.ur.getHoverThrust(0.5*vecnorm([data.motRpm_RF, data.motRpm_LF, data.motRpm_LB, data.motRpm_RB],2,2));
            thrustNED = obj.uf.XYZ2NED([zeros(size(thrust,1),2), -thrust], data.q1, data.q2, data.q3, data.q4);
            
%             An = @(roll, pitch, yaw) sin(pitch) .* cos(roll) .* cos(yaw) + sin(roll) .* sin(yaw);
%             Ae = @(roll, pitch, yaw) sin(pitch) .* sin(roll) .* cos(yaw) - cos(roll) .* sin(yaw);
%             Ad = @(roll, pitch, yaw) cos(pitch)              .* cos(yaw);
%             
            aNED = obj.uf.XYZ2NED([data.ax, data.ay, data.az], data.q1, data.q2, data.q3, data.q4);

%             Dn = An(data.roll, data.pitch, data.yaw) .* thrust - (aNED(:,1) + 0             ) .* obj.para.cst.m;
%             De = Ae(data.roll, data.pitch, data.yaw) .* thrust - (aNED(:,2) + 0             ) .* obj.para.cst.m;
%             Dd = Ad(data.roll, data.pitch, data.yaw) .* thrust - (aNED(:,3) + 0             ) .* obj.para.cst.m;
%             Dd = Ad(data.roll, data.pitch, data.yaw) .* thrust - (aNED(:,3) + obj.para.cst.g) .* obj.para.cst.m;
            
            % TODO : write nicely down the physics of this
            dragNED = thrustNED - aNED .* obj.para.cst.m;
            ttDragNED = timetable(dragNED, 'RowTimes', data.Time);
        end

        function ttWind = computeWind(obj, data, ttDragNED)
            % Transform to Tilt frame
            dragTilt = obj.uf.NED2Tilt(ttDragNED.dragNED, data.roll, data.pitch, data.yaw);

            % Compute ws in the [Tx, Tz] plane
            dragMagTxTz = vecnorm([dragTilt(:,1), dragTilt(:,3)],2,2);
            dragAngleTxTz = atan2(dragTilt(:,3), dragTilt(:,1));
            alpha = obj.uf.computeTilt(data.roll, data.pitch);
            RPM = mean([data.motRpm_RF, data.motRpm_LF, data.motRpm_LB, data.motRpm_RB], 2);
            tasTxTz = obj.ur.getTrueAirSpeed(alpha, RPM, dragMagTxTz);

            % Compute ws along [Ty]
            tasTy = sign(dragTilt(:,2)).*obj.ur.getTrueAirSpeed(zeros(size(RPM)), RPM, abs(dragTilt(:,2)));

            % Transform back to NED frame
            tasNED = obj.uf.Tilt2NED([tasTxTz.*cos(dragAngleTxTz), tasTxTz.*sin(dragAngleTxTz), tasTy], data.roll, data.pitch, data.yaw);

            % Compute wind 
            ws = obj.uf.getWindSpeed(tasNED, [data.vn, data.ve, data.vd]);
            [windHDir_est, windHMag_est, windVert_est] = obj.uf.getHWind(ws);
            ttWind = timetable(windHDir_est, windHMag_est, windVert_est, 'RowTimes', ttDragNED.Time);
        end
        

        function tt = estimateWind(obj, data)
            drag = obj.computeDrag(data);
            wind = obj.computeWind(data, drag);
            tt = synchronize(wind, data);
        end
    end
end
