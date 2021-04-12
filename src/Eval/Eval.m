classdef Eval
    properties
        para
        data
    end
    
    methods
        % Constructor
        function obj = Eval(para)
            obj.para = para;
            
            for i = 1:length(obj.para.inputPath)
        		obj.data{i} = load(obj.para.inputPath(i)).tt;
        	end
        end

        function plotValueOverFlight(obj, flightName)
        	legend_windHMag = [];
        	legend_windHDir = [];

        	figure(1)
        	clf
        	hold on

        	firstRef = true;
        	for i = 1:length(obj.data)
        		if obj.data{i}.Properties.CustomProperties.FlightName ~= flightName
        			continue;
        		end

        		if firstRef 
        			firstRef = false;
        			% Plot windHMag ref
        			subplot(2,1,1), hold on
        			plot(obj.data{i}.Time, obj.data{i}.windHMag)
        			legend_windHMag = [legend_windHMag, "Reference"];
        			
        			subplot(2,1,2), hold on 
        			plot(obj.data{i}.Time, obj.data{i}.windHDir)
        			legend_windHDir = [legend_windHDir, "Reference"];
        		end

        		% Plot windHMag
        		subplot(2,1,1), hold on
        		plot(obj.data{i}.Time, obj.data{i}.windHMag_est)
        		legend_windHMag = [legend_windHMag, obj.data{i}.Properties.CustomProperties.Method];


        		% Plot windHDir
        		subplot(2,1,2), hold on
        		plot(obj.data{i}.Time, obj.data{i}.windHDir_est)
        		legend_windHDir = [legend_windHDir, obj.data{i}.Properties.CustomProperties.Method];

        	end
    		
    		sgtitle({'Horizontal wind for flight :', strrep(flightName, '_', '\_')});
    		subplot(2,1,1), ylabel("Wind Mag [m/s]"), legend(legend_windHMag)
    		subplot(2,1,2), ylabel("Wind Dir [deg]"), xlabel("Time"), legend(legend_windHDir)
    		hold off

        end


        function plotErrorOverFlight(obj)
        end

    end
end


        
