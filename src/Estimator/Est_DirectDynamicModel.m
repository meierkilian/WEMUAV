classdef Est_DirectDynamicModel
    properties
        para
        ur % Frame transformation utility
    end
    
    methods
        function obj = Est_DirectDynamicModel(para)
            obj.para = para;
            obj.ur = Util_Frame();
        end
        
        function ttDrag = computeDrag(obj, data)
            thrust = obj.computeThrustFromRPM(data);
            
            An = @(roll, pitch, yaw) sin(pitch) .* cos(roll) .* cos(yaw) + sin(roll) .* sin(yaw);
            Ae = @(roll, pitch, yaw) sin(pitch) .* sin(roll) .* cos(yaw) - cos(roll) .* sin(yaw);
            Ad = @(roll, pitch, yaw) cos(pitch)              .* cos(yaw);
            
            aNED = obj.ur.XYZ2NED([data.ax, data.ay, data.az], data.q1, data.q2, data.q3, data.q4);

            Dn = An(data.roll, data.pitch, data.yaw) .* thrust - (aNED(:,1) + 0             ) .* obj.para.cst.m;
            De = Ae(data.roll, data.pitch, data.yaw) .* thrust - (aNED(:,2) + 0             ) .* obj.para.cst.m;
            Dd = Ad(data.roll, data.pitch, data.yaw) .* thrust - (aNED(:,3) + obj.para.cst.g) .* obj.para.cst.m;

            ttDrag = timetable(Dn, De, Dd, 'TimeRows', data.Time);
        end
        
        function ttThrust = computeThrustFromRPM(obj, data)
            % TODO : TBI
        end


        function ttSpeed = computeWindSpeed(obj, ttDrag)
            % TODO : TBI
        end
        

        function ttDir = computeWindDirection(obj, ttDrag)
            dir = atan2(drag.y, drag.x); % TODO : check orientation of reference frame
            ttDir = timetable(dir, 'RowTimes', drag.Time);
        end

        
        function tt = estimateWind(obj, data)
            drag = obj.computeDrag(data)
            speed = obj.computeWindSpeed(drag);
            dir = obj.computeWindDirection(drag);
            ref = timetable(data.windHMag, data.windHDir, 'RowTimes', data.Time, 'VariableNames', {'windHMag', 'windHDir'});
            tt = synchronize(speed, dir, ref);
        end
    end
end
