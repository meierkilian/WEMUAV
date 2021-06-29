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
        function obj = Est_GarreauSimple(para)
            % Constructor
            % INPUT : 
            %   para : parameter set as a structure
            % OUTPUT : 
            %   obj : constructed object

            obj.para = para;
            obj.uf = Util_Frame();
        end
        
        function speed = computeWindSpeed(obj, data)
            % Performs wind speed estimation
            % INPUT :
            %   data : timetable of data as outputed by the preprocessing
            % OUTPUT :
            %   speed : timetable of wind speed estimation (windHMag_est)

            [tilt, ~] = obj.uf.computeTilt(data.q1, data.q2, data.q3, data.q4);
            
            test = find(abs(tan(tilt)) > obj.para.reg.cut) ; 
            windHMag_est = sqrt(obj.para.reg.a0 * abs(tan(tilt).^2)) ; %case alpha <= tan(gamma_crit)
            windHMag_est(test) = sqrt(obj.para.reg.a1 * abs(tan(tilt(test))) + obj.para.reg.a2) ; %case alpha > tan(gamma_crit)
            speed = timetable(windHMag_est, 'RowTimes', data.Time);
        end
        
        function dir = computeWindDirection(obj, data)
            % Performs wind direction estimation 
            % INPUT :
            %   data : timetable of data as outputed by the preprocessing
            % OUTPUT :
            %   dir : timetable of wind direction estimation (windHDir_est)

            [~, windHDir_est] = obj.uf.computeTilt(data.q1, data.q2, data.q3, data.q4);
            windHDir_est = rad2deg(windHDir_est);
            dir = timetable(windHDir_est, 'RowTimes', data.Time);
        end
        
        function tt = estimateWind(obj, data)
            % Performs wind estimation
            % INPUT :
            %   data : timetable of data as outputed by the preprocessing
            % OUTPUT :
            %   dir : timetable containing the input data as well as the 
            %         wind speed and direction estimation (windHMag_est, windHDir_est)
            
            speed = obj.computeWindSpeed(data);
            dir = obj.computeWindDirection(data);
            ws = obj.uf.getNEDWind(dir.windHDir_est, speed.windHMag_est, zeros(size(speed.windHMag_est)));
            ttws = timetable(ws, 'RowTimes', data.Time);
            tt = synchronize(speed, dir, ttws, data);
        end
    end
end
