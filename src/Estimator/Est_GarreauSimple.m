classdef Est_GarreauSimple
    % This estimator is based on the work of Arthur Garreau (2020), in his
    % work this estimation is refered as "simple method". To be more
    % specific, the wind speed was empirically correlated to the tilt angle
    % of the drone and wind direction is computed from the direction of tilt.
    
    properties
        para % Parameter set
        uf % Frame utility object
    end
    
    methods
        % Constructor
        % INPUT : 
        %   para : parameter set as a structure
        % OUTPUT : 
        %   obj : constructed object
        function obj = Est_GarreauSimple(para)
            obj.para = para;
            obj.uf = Util_Frame();
        end
        
        % Performs wind speed estimation
        % INPUT :
        %   data : timetable of data as outputed by the preprocessing
        % OUTPUT :
        %   speed : timetable of wind speed estimation (windHMag_est)
        function speed = computeWindSpeed(obj, data)
            [tilt, ~] = obj.uf.computeTilt(data.q1, data.q2, data.q3, data.q4);
            
            test = find(abs(tan(tilt)) > obj.para.reg.cut) ; 
            windHMag_est = sqrt(obj.para.reg.alpha1 * abs(tan(tilt).^2)) ; %case alpha <= tan(gamma_crit)
            windHMag_est(test) = sqrt(obj.para.reg.alpha2 * abs(tan(tilt(test))) + obj.para.reg.beta) ; %case alpha > tan(gamma_crit)
            speed = timetable(windHMag_est, 'RowTimes', data.Time);
        end
        
        % Performs wind direction estimation 
        % INPUT :
        %   data : timetable of data as outputed by the preprocessing
        % OUTPUT :
        %   dir : timetable of wind direction estimation (windHDir_est)
        function dir = computeWindDirection(obj, data)
            [~, windHDir_est] = obj.uf.computeTilt(data.q1, data.q2, data.q3, data.q4);
            windHDir_est = rad2deg(windHDir_est);
            dir = timetable(windHDir_est, 'RowTimes', data.Time);
        end
        
        % Performs wind estimation
        % INPUT :
        %   data : timetable of data as outputed by the preprocessing
        % OUTPUT :
        %   dir : timetable containing the input data as well as the 
        %         wind speed and direction estimation (windHMag_est, windHDir_est)
        function tt = estimateWind(obj, data)
            speed = obj.computeWindSpeed(data);
            dir = obj.computeWindDirection(data);
            tt = synchronize(speed, dir, data);
        end
    end
end
