classdef Eval < handle
	properties
		para
		data
		figIdx
	end
	
	methods
		% Constructor
		function obj = Eval(para)
			obj.para = para;
			obj.figIdx = 1;
			
			for i = 1:length(obj.para.inputPath)
				obj.data{i} = load(obj.para.inputPath(i)).tt;
			end
		end

		function plotValueOverFlight(obj, flightName)
			legend_windHMag = [];
			legend_windHDir = [];
			legend_windVert = [];

			figure(obj.figIdx)
			obj.figIdx = obj.figIdx + 1;
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
					subplot(3,1,1), hold on
					plot(obj.data{i}.Time, obj.data{i}.windHMag_2130cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windHMag_1800cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windHMag_1470cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windHMag_other)
					legend_windHMag = [legend_windHMag, "Ref 21.3m", "Ref 18.0m", "Ref 14.7m", "Phantom"];
					
					subplot(3,1,2), hold on 
					plot(obj.data{i}.Time, obj.data{i}.windHDir_2130cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windHDir_1800cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windHDir_1470cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windHDir_other)
					legend_windHDir = [legend_windHDir, "Ref 21.3m", "Ref 18.0m", "Ref 14.7m", "Phantom"];

					subplot(3,1,3), hold on 
					plot(obj.data{i}.Time, obj.data{i}.windVert_2130cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windVert_1800cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windVert_1470cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windVert_other)
					legend_windVert = [legend_windVert, "Ref 21.3m", "Ref 18.0m", "Ref 14.7m", "Phantom"];
				end

				% Plot windHMag
				subplot(3,1,1), hold on
				plot(obj.data{i}.Time, obj.data{i}.windHMag_est)
				legend_windHMag = [legend_windHMag, obj.data{i}.Properties.CustomProperties.Method];


				% Plot windHDir
				subplot(3,1,2), hold on
				plot(obj.data{i}.Time, obj.data{i}.windHDir_est)
				legend_windHDir = [legend_windHDir, obj.data{i}.Properties.CustomProperties.Method];

				% Plot windVert
				if ismember('windVert_est',obj.data{i}.Properties.VariableNames)
					subplot(3,1,3), hold on
					plot(obj.data{i}.Time, obj.data{i}.windVert_est)
					legend_windVert = [legend_windVert, obj.data{i}.Properties.CustomProperties.Method];
				end

			end
			
			sgtitle({'Horizontal wind for flight :', strrep(flightName, '_', '\_')});
			subplot(3,1,1), ylabel("Wind Mag [m/s]"), xlabel("Time"), legend(legend_windHMag)
			subplot(3,1,2), ylabel("Wind Dir [deg]"), xlabel("Time"), legend(legend_windHDir)
			subplot(3,1,3), ylabel("Wind Vert [m/s]"), xlabel("Time"), legend(legend_windVert)
			hold off

		end


		function plotErrorOverFlight(obj)
		end

	end
end


		
