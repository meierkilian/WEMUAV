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
        
        function tilt = computeTilt(obj, roll, pitch, yaw)
        end
        
        function coeff = computeDragCoeff(obj)
        end
        
        function speed = computeWindSpeed(obj, data)
        end
        
        function dir = computeWindDirection(obj, data)
            
        end
        
        function tt = estimateWind(obj, data)
            speed = obj.computeWindSpeed(data);
            dir = obj.computeWindDirection(data);
            tt = synchronise(speed, dir);
        end
    end
end
