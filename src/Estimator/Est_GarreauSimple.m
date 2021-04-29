classdef Est_GarreauSimple
    % This estimator is based on the work of Arthur Garreau (2020), in his
    % work this estimation is refered as "simple method". To be more
    % specific, the drag force is directly computed from the drone's tilt
    % angle (assuming the drone is stationnary), the drag coefficients are
    % infered from wind tunnel tests See Russel et al. (2016) :
    % https://ntrs.nasa.gov/search.jsp?R=20160007399. 
    
    properties
        para
    end
    
    methods
        function obj = Est_GarreauSimple(para)
            obj.para = para;
        end
        
        function [tilt, norm_p, p_dot_n] = computeTilt(~, data)
            norm_p = sqrt((cos(data.roll).*sin(data.pitch)).^2 + (sin(data.roll).*cos(data.pitch)).^2 + (cos(data.roll).*cos(data.pitch)).^2);
            p_dot_n = -cos(data.pitch).*cos(data.roll);
            tilt = acos(p_dot_n ./ norm_p);
        end
        
        % % calc_Dnasa(PHANTOM, tilt, PATH.DRAG_DATA)
        % function coeff = computeDragCoeffNASA(obj, data, tilt)
        %     % TODO : clean this function
        %     coeff = old_calc_Dnasa(data, tilt, obj.para.dragDataPath);
        % end
        
        % function speed = computeWindSpeedNASA(obj, data)
        %     [tilt, ~, ~] = obj.computeTilt(data);

        %     D_simple = obj.para.cst.m * obj.para.cst.g * abs(tan(tilt));
        %     Dnasa = obj.computeDragCoeffNASA(data, tilt);

        %     windHMag_est = sqrt(2*D_simple ./ (obj.para.cst.rho*abs(Dnasa)/obj.para.cst.qnasa));

        %     speed = timetable(windHMag_est, 'RowTimes', data.Time);
        % end

        function speed = computeWindSpeed(obj, data)
            [tilt, ~, ~] = obj.computeTilt(data);
            test = find(abs(tan(tilt)) > obj.para.reg.cut) ; 
            windHMag_est = sqrt(obj.para.reg.alpha1 * abs(tan(tilt).^2)) ; %case alpha <= tan(gamma_crit)
            windHMag_est(test) = sqrt(obj.para.reg.alpha2 * abs(tan(tilt(test))) + obj.para.reg.beta) ; %case alpha > tan(gamma_crit)
            speed = timetable(windHMag_est, 'RowTimes', data.Time);
        end
        
        function dir = computeWindDirection(obj, data)
            % Computing direction
            % TODO : why is norm_p and p_dot_n not the same as in compute tile ?
            norm_p = sqrt((cos(data.roll).*sin(data.pitch)).^2 + (sin(data.roll).*cos(data.pitch)).^2);
            p_dot_n = - cos(data.roll).*sin(data.pitch);
            lambda = acos(p_dot_n ./ norm_p) * 180/pi;  % [°]

            % "Map" direction to [0;360]
            test = sin(data.roll).*cos(data.pitch) >= 0 ;  

            windHDir_est = zeros(length(data.roll),1);
            windHDir_est(~test) = mod(360 - lambda(~test) + rad2deg(data.yaw(~test)),360);  % [°] 
            windHDir_est(test) = mod(lambda(test) + rad2deg(data.yaw(test)),360);        % [°] 

            dir = timetable(windHDir_est, 'RowTimes', data.Time);
        end
        
        function tt = estimateWind(obj, data)
            speed = obj.computeWindSpeed(data);
            dir = obj.computeWindDirection(data);
            tt = synchronize(speed, dir, data);
        end
    end
end
