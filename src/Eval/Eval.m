% TODO : comment
classdef Eval < handle
	properties
		para
		data
		figIdx
		flightList
		methodList
		figFlightList
	end
	
	methods
		% Constructor
		function obj = Eval(para)
			obj.para = para;
			obj.figIdx = 100;
			obj.flightList = "";
			obj.methodList = "";
			obj.figFlightList = [];
			
			for i = 1:length(obj.para.inputPath)
				obj.data{i} = load(obj.para.inputPath(i)).tt;
				obj.flightList(i) = string(obj.data{i}.Properties.CustomProperties.FlightName);
				obj.methodList(i) = string(obj.data{i}.Properties.CustomProperties.Method); 
			end
			obj.flightList = unique(obj.flightList);
			obj.methodList = unique(obj.methodList);
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
			
			sgtitle({'Wind for flight :', strrep(flightName, '_', '\_')});
			subplot(3,1,1), ylabel("Wind Mag [m/s]"), xlabel("Time"), legend(legend_windHMag)
			subplot(3,1,2), ylabel("Wind Dir [deg]"), xlabel("Time"), legend(legend_windHDir)
			subplot(3,1,3), ylabel("Wind Vert [m/s]"), xlabel("Time"), legend(legend_windVert)
			hold off
		end


		function plotErrorOverFlight(obj, flightname)
			legend_windHMag = [];
			legend_windHDir = [];
			legend_windVert = [];

			figure(obj.figIdx)
			obj.figIdx = obj.figIdx + 1;
			clf
			hold on


			firstRef = true;
			for i = 1:length(obj.data)
				if obj.data{i}.Properties.CustomProperties.FlightName ~= flightname
					continue;
				end

				if firstRef 
					firstRef = false;
					
					meanRef_windHMag = mean([obj.data{i}.windHMag_2130cm, obj.data{i}.windHMag_1800cm, obj.data{i}.windHMag_1470cm], 2, 'omitnan');
					meanRef_windHDir = mean([obj.data{i}.windHDir_2130cm, obj.data{i}.windHDir_1800cm, obj.data{i}.windHDir_1470cm], 2, 'omitnan');
					meanRef_windVert = mean([obj.data{i}.windVert_2130cm, obj.data{i}.windVert_1800cm, obj.data{i}.windVert_1470cm], 2, 'omitnan');
				end

				


				% windHMag
				[error_windHMag, bias_windHMag, std_windHMag, errorStr_windHMag] = obj.computeError( ...
						[obj.data{i}.windHMag_2130cm, obj.data{i}.windHMag_1800cm, obj.data{i}.windHMag_1470cm], ...
						obj.data{i}.windHMag_est);
				subplot(3,1,1), hold on
				plot(obj.data{i}.Time, error_windHMag)
				legend_windHMag = [legend_windHMag, obj.data{i}.Properties.CustomProperties.Method + errorStr_windHMag];


				% windHDir
				[error_windHDir, bias_windHDir, std_windHDir, errorStr_windHDir] = obj.computeError( ...
						[obj.data{i}.windHDir_2130cm, obj.data{i}.windHDir_1800cm, obj.data{i}.windHDir_1470cm], ...
						obj.data{i}.windHDir_est);
				subplot(3,1,2), hold on
				plot(obj.data{i}.Time, error_windHDir)
				legend_windHDir = [legend_windHDir, obj.data{i}.Properties.CustomProperties.Method + errorStr_windHDir];


				% windVert
				if ismember('windVert_est',obj.data{i}.Properties.VariableNames)
					[error_windVert, bias_windVert, std_windVert, errorStr_windVert] = obj.computeError( ...
							[obj.data{i}.windVert_2130cm, obj.data{i}.windVert_1800cm, obj.data{i}.windVert_1470cm], ...
							obj.data{i}.windVert_est);
					subplot(3,1,3), hold on
					plot(obj.data{i}.Time, error_windVert)
					legend_windVert = [legend_windVert, obj.data{i}.Properties.CustomProperties.Method + errorStr_windVert];
				end

			end
			
			sgtitle({'Error on wind for flight :', strrep(flightname, '_', '\_')});
			subplot(3,1,1), ylabel("Wind Mag [m/s]"), xlabel("Time"), legend(legend_windHMag)
			subplot(3,1,2), ylabel("Wind Dir [deg]"), xlabel("Time"), legend(legend_windHDir)
			subplot(3,1,3), ylabel("Wind Vert [m/s]"), xlabel("Time"), legend(legend_windVert)
			hold off
		end


		function [error, err_bias, err_std, errorStr] = computeError(~, ref, data)
			meanRef = mean(ref,2,'omitnan');
			error = data - meanRef;
			err_bias = mean(error, 'omitnan');
			err_std = std(error, 'omitnan');
			err_median = median(error, 'omitnan');
			errorStr = sprintf(" Bias : %.2f, Median : %.2f, Std : %.2f, MeanRef : %.2f", err_bias, err_median, err_std, mean(meanRef));
		end

		function dispAllMagErr(obj)
			res = "";
			
			for i = 1:length(obj.data)
				if ~ismember('windHMag_2130cm', obj.data{i}.Properties.VariableNames)
					errStr = ""; % skipping flights which do not have a ref yet 
				else
					[~, ~, ~, errStr] = obj.computeError( ...
							[obj.data{i}.windHMag_2130cm, obj.data{i}.windHMag_1800cm, obj.data{i}.windHMag_1470cm], ...
							obj.data{i}.windHMag_est);
				end
				flightIdx = obj.data{i}.Properties.CustomProperties.FlightName == obj.flightList;
				methodIdx = obj.data{i}.Properties.CustomProperties.Method == obj.methodList;
				res(flightIdx, methodIdx) = errStr;
			end
			t = array2table(res, 'VariableNames', obj.methodList, 'RowNames', obj.flightList);
			disp(t);
		end
	end
end


		
