% TODO : comment
classdef Eval < handle
	properties
		para
		data
		figIdx
		flightList
		flightTypeList
		methodList
		figFlightList
		perf
		legMap
	end
	
	methods
		% Constructor
		function obj = Eval(para)
			obj.para = para;
			obj.figIdx = 100;
			obj.flightList = "";
			obj.methodList = "";
            obj.flightTypeList = "";
			obj.figFlightList = [];
			
			for i = 1:length(obj.para.inputPath)
				obj.data{i} = load(obj.para.inputPath(i)).tt;
				obj.flightList(i) = string(obj.data{i}.Properties.CustomProperties.FlightName);
				obj.methodList(i) = string(obj.data{i}.Properties.CustomProperties.Method); 
				obj.flightTypeList(i) = string(obj.data{i}.Properties.CustomProperties.FlightType); 
			end
			obj.flightList = unique(obj.flightList);
			obj.methodList = unique(obj.methodList);
			obj.flightTypeList = unique(obj.flightTypeList);
			obj.perf = {};
			obj.legMap = containers.Map({'directdynamicmodel_linVert',   'directdynamicmodel_linNoVert',    'directdynamicmodel_quadVert', 'directdynamicmodel_quadNoVert', 'garreausimple'}, ...
									{'DM, Linear and Vertical Drag', 'DM, Linear and No Vertical Drag', 'DM, Quadratic and Vertical Drag', 'DM, Quadratic and No Vertical Drag', 'Tilt'}) ;			

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

				if firstRef && ismember("windHMag_2130cm", obj.data{i}.Properties.VariableNames)
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
                elseif firstRef
                    firstRef = false;
                    % Plot windHMag ref
					subplot(3,1,1), hold on
					plot(obj.data{i}.Time, obj.data{i}.windHMag_1140cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windHMag_0150cm, '--')
					legend_windHMag = [legend_windHMag, "Ref 11.4m", "Ref 1.5m"];
					
					subplot(3,1,2), hold on 
					plot(obj.data{i}.Time, obj.data{i}.windHDir_1140cm, '--')
					plot(obj.data{i}.Time, obj.data{i}.windHDir_0150cm, '--')
					legend_windHDir = [legend_windHDir, "Ref 11.4m", "Ref 1.5m"];

					subplot(3,1,3), hold on 
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

		function plotValueOverFlight_pretty(obj, flightName)
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

				if flightName == "FLY139__20210420_092926__Hover"
					tmp = obj.data{i};
					startIdx = find(tmp.Time > datetime(2021,04,20,09,31,0),1)
					endIdx = find(tmp.Time > datetime(2021,04,20,09,34,0),1)-1
					obj.data{i} = tmp(startIdx:endIdx, :);
				end

				if firstRef
					firstRef = false;
					lw = 3;
					% Plot windHMag ref
					subplot(3,1,1), hold on
					plot(obj.data{i}.Time, mean([obj.data{i}.windHMag_2130cm, obj.data{i}.windHMag_1800cm, obj.data{i}.windHMag_1470cm], 2), 'LineWidth',lw)
					legend_windHMag = [legend_windHMag, "Reference"];
					
					subplot(3,1,2), hold on 
					plot(obj.data{i}.Time, mean([obj.data{i}.windHDir_2130cm, obj.data{i}.windHDir_1800cm, obj.data{i}.windHDir_1470cm], 2), 'LineWidth',lw)
					legend_windHDir = [legend_windHDir, "Reference"];

					subplot(3,1,3), hold on 
					plot(obj.data{i}.Time, mean([obj.data{i}.windVert_2130cm, obj.data{i}.windVert_1800cm, obj.data{i}.windVert_1470cm], 2), 'LineWidth',lw)
					legend_windVert = [legend_windVert, "Reference"];
                end

				% Plot windHMag
				subplot(3,1,1), hold on
				plot(obj.data{i}.Time, obj.data{i}.windHMag_est)
				legend_windHMag = [legend_windHMag, obj.legMap(obj.data{i}.Properties.CustomProperties.Method)];


				% Plot windHDir
				subplot(3,1,2), hold on
				plot(obj.data{i}.Time, obj.data{i}.windHDir_est)
				legend_windHDir = [legend_windHDir, obj.legMap(obj.data{i}.Properties.CustomProperties.Method)];

				% Plot windVert
				subplot(3,1,3), hold on
				if ismember('windVert_est',obj.data{i}.Properties.VariableNames)
					plot(obj.data{i}.Time, obj.data{i}.windVert_est)
				else 
					plot(obj.data{i}.Time, zeros(size(obj.data{i}.Time)))
				end
				legend_windVert = [legend_windVert, obj.legMap(obj.data{i}.Properties.CustomProperties.Method)];
			end
			
			sgtitle({'Wind for flight :', strrep(flightName, '_', '\_')});
			subplot(3,1,1), ylabel("Wind Mag [m/s]"), xlabel("Time"), legend(legend_windHMag,'location','eastoutside'), grid on
			subplot(3,1,2), ylabel("Wind Dir [deg]"), xlabel("Time"), legend(legend_windHDir,'location','eastoutside'), grid on
			subplot(3,1,3), ylabel("Wind Vert [m/s]"), xlabel("Time"), legend(legend_windVert,'location','eastoutside'), grid on
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
			[c,l] = xcorr(data, meanRef, 30/0.1 );
			[~, i] = max(c);

			errorStr = sprintf(" Bias : %.2f, Median : %.2f, Std : %.2f, MeanRef : %.2f, xcorr : %.2f", err_bias, err_median, err_std, mean(meanRef), l(i)*0.1);
		end

		
		function Tperf = singleFlightPerf(obj, flightName)
			windAziNoFiltBias = [];
			windAziNoFiltStd = [];
			windAziFiltBias = [];
			windAziFiltStd = [];
			windVertNoFiltBias = [];
			windVertNoFiltStd = [];
			windVertFiltBias = [];
			windVertFiltStd = [];
			refErrBias = [];
			refErrStd = [];
            refErrBiasVert = [];
			refErrStdVert = [];
			methods = [];
			uf = Util_Frame();
			d = designfilt('lowpassfir','FilterOrder',50,'CutoffFrequency',0.1,'SampleRate',10); % TODO: magic number here !

			for i = 1:length(obj.data)
				if obj.data{i}.Properties.CustomProperties.FlightName ~= flightName
					continue;
				end
				flightType = obj.data{i}.Properties.CustomProperties.FlightType;
                if ~ismember("windHDir_2130cm",obj.data{i}.Properties.VariableNames) % TODO: quick and dirty, check for alti of drone to choose correct reference ? 
                    meanRefDir = mean([obj.data{i}.windHDir_1140cm, obj.data{i}.windHDir_0150cm],2);
                    meanRefMag = mean([obj.data{i}.windHMag_1140cm, obj.data{i}.windHMag_0150cm],2);
                    meanRefVert = zeros(size(meanRefMag));
                else   
                    meanRefDir = mean([obj.data{i}.windHDir_2130cm, obj.data{i}.windHDir_1800cm, obj.data{i}.windHDir_1470cm],2);
                    meanRefMag = mean([obj.data{i}.windHMag_2130cm, obj.data{i}.windHMag_1800cm, obj.data{i}.windHMag_1470cm],2);
                    meanRefVert = mean([obj.data{i}.windVert_2130cm, obj.data{i}.windVert_1800cm, obj.data{i}.windVert_1470cm],2);
                end
				refNED_2130 = uf.getNEDWind(obj.data{i}.windHDir_2130cm, obj.data{i}.windHMag_2130cm, obj.data{i}.windVert_2130cm);
				refNED_1800 = uf.getNEDWind(obj.data{i}.windHDir_1800cm, obj.data{i}.windHMag_1800cm, obj.data{i}.windVert_1800cm);
				refNED_1470 = uf.getNEDWind(obj.data{i}.windHDir_1470cm, obj.data{i}.windHMag_1470cm, obj.data{i}.windVert_1470cm);
				refNED = uf.getNEDWind(meanRefDir, meanRefMag, meanRefVert);

				errorNED = refNED - obj.data{i}.ws;
				biasAzi = mean(errorNED(:,1:2),1);
				biasVert = mean(errorNED(:,3));
				stdAzi = norm([std(errorNED(:,1)), std(errorNED(:,2))]);
				stdVert = std(errorNED(:,3));
				
				errorNEDFilt = filtfilt(d, refNED) - filtfilt(d, obj.data{i}.ws);
				biasAziFilt = mean(errorNEDFilt(:,1:2),1);
				biasVertFilt = mean(errorNEDFilt(:,3));
				stdAziFilt = norm([std(errorNEDFilt(:,1)), std(errorNEDFilt(:,2))]);
				stdVertFilt = std(errorNEDFilt(:,3));

				methods = [methods, obj.data{i}.Properties.CustomProperties.Method];
				windAziNoFiltBias 	= [windAziNoFiltBias; norm(biasAzi)];
				windAziNoFiltStd 	= [windAziNoFiltStd; stdAzi];
				
				windVertNoFiltBias 	= [windVertNoFiltBias; abs(biasVert)];
				windVertNoFiltStd 	= [windVertNoFiltStd; stdVert];

				
				windAziFiltBias 		= [windAziFiltBias; norm(biasAziFilt)];
				windAziFiltStd 		= [windAziFiltStd; stdAziFilt];
				windVertFiltBias 		= [windVertFiltBias; norm(biasVertFilt)];
				windVertFiltStd 		= [windVertFiltStd; stdVertFilt];

				errRefNED = refNED_2130 - refNED_1470;

				refErrBias = [refErrBias; norm(mean(errRefNED(:,1:2), 1))];
				refErrStd = [refErrStd; norm([std(errRefNED(:,1)), std(errRefNED(:,2))])];
				refErrBiasVert = [refErrBiasVert; norm(mean(errRefNED(:,3), 1))];
				refErrStdVert = [refErrStdVert; std(errRefNED(:,3))];
			end

			Tperf = table(windAziNoFiltBias, ...
						  windAziNoFiltStd, ...
						  windAziFiltBias, ...
						  windAziFiltStd, ...
						  windVertNoFiltBias, ...
						  windVertNoFiltStd, ...
						  windVertFiltBias, ...
						  windVertFiltStd, ...
						  refErrBias, ...
						  refErrStd, ...
						  refErrBiasVert, ...
						  refErrStdVert, ...
						  'RowNames', methods ...
						  );
			


			Tperf = addprop(Tperf, {'meanWindHMag', 'FlightType'}, {'table', 'table'});
			Tperf.Properties.CustomProperties.meanWindHMag = mean(meanRefMag);
			Tperf.Properties.CustomProperties.FlightType = flightType;
		end


		function plotErrorOverWind(obj, method, flightType, filter, plotStd)

			if isempty(obj.perf)
				for i = 1:length(obj.flightList)
					obj.perf{i} = obj.singleFlightPerf(obj.flightList(i));
				end
			end

			if filter
				filtString = ", Lowpass filtered (0.5 Hz Cutoff)";
			else
				filtString = "";
			end

			figure(obj.figIdx)
			obj.figIdx = obj.figIdx + 1;
			clf
			hold on
			title("Azimuthal Error over wind speed","FlightType : " + flightType + filtString)
			xlabel("Wind speed [m/s]")
			ylabel("Mean Error [m/s]")
			axis square
			grid on

			if method == "all"
				method = obj.methodList;
			end
			if flightType == "all" 
				flightType = obj.flightTypeList;
			elseif flightType == "each"
				for i = 1:length(obj.flightTypeList)
					obj.plotErrorOverWind(method, obj.flightTypeList(i))
				end
				return
			elseif flightType == "Vertical"
				flightType = ["Vertical2ms","Vertical3ms","Vertical4ms","Vertical5ms"];
			end

			for i = 1:length(method)
				w = nan(length(obj.flightList),1);
				bias = nan(length(obj.flightList),1);
				std = nan(length(obj.flightList),1);
				biasFilt = nan(length(obj.flightList),1);
				stdFilt = nan(length(obj.flightList),1);
				refErrBias = nan(length(obj.flightList),1);
				refErrStd = nan(length(obj.flightList),1);


				for j = 1:length(obj.flightList)
					if ~ismember(obj.perf{j}.Properties.CustomProperties.FlightType, flightType)
						continue
					end
					tmp = obj.perf{j};
					bias(j) = tmp{method(i), "windAziNoFiltBias"};
					std(j) = tmp{method(i), "windAziNoFiltStd"};
					biasFilt(j) = tmp{method(i), "windAziFiltBias"};
					stdFilt(j) = tmp{method(i), "windAziFiltStd"};				
					w(j) = tmp.Properties.CustomProperties.meanWindHMag;
					
				end
				
				bias = rmmissing(bias);
				std = rmmissing(std);
				biasFilt = rmmissing(biasFilt);
				stdFilt = rmmissing(stdFilt);
				refErrBias = rmmissing(refErrBias);
				refErrStd = rmmissing(refErrStd);
				w = rmmissing(w);

				t = table(w, bias, std, biasFilt, stdFilt,refErrBias,refErrStd);
				t = sortrows(t);

				leg = values(obj.legMap, cellstr(method));
				if filter
					if plotStd
						plot(t.w, t.biasFilt,'-o','Color', '#0072BD')
						plot(t.w, t.biasFilt + t.stdFilt, '--', 'Color', '#0072BD')
						plot(t.w, t.biasFilt - t.stdFilt, '--', 'Color', '#0072BD')
						patch([t.w; flip(t.w)], [t.biasFilt + t.stdFilt; flip(t.biasFilt - t.stdFilt)],[0 0.4470 0.7410],'FaceAlpha',0.2, 'EdgeColor','none' )

						leg = [leg "1\sigma deviation"];
					else	
						plot(t.w, t.biasFilt,'-o')
					end
				else
					if plotStd
						plot(t.w, t.bias,'-o','Color', '#0072BD')
						plot(t.w, t.bias + t.std, '--', 'Color', '#0072BD')
						plot(t.w, t.bias - t.std, '--', 'Color', '#0072BD')
						patch([t.w; flip(t.w)], [t.bias + t.std; flip(t.bias - t.std)],[0 0.4470 0.7410],'FaceAlpha',0.2, 'EdgeColor','none' )
						leg = [leg "1\sigma deviation"];
					else	
						plot(t.w, t.bias,'-o')
					end
				end
			end
			legend(leg, 'location', 'eastoutside')
		end

		function plotErrorOverWind_total(obj, flightType)
			if isempty(obj.perf)
				for i = 1:length(obj.flightList)
					obj.perf{i} = obj.singleFlightPerf(obj.flightList(i));
				end
            end


			figure(obj.figIdx)
			obj.figIdx = obj.figIdx + 1;
			clf
			ax = [];
			tiledlayout(3,2)

			titleFlightType = flightType;

			if flightType == "all" 
				flightType = obj.flightTypeList;
			elseif flightType == "Vertical"
				flightType = ["Vertical2ms","Vertical3ms","Vertical4ms","Vertical5ms"];
			end

			for i = 1:length(obj.methodList)
				w = nan(length(obj.flightList),1);
				bias = nan(length(obj.flightList),1);
				std = nan(length(obj.flightList),1);
                refErrBias = nan(length(obj.flightList),1);
                refErrStd = nan(length(obj.flightList),1);
                
				for j = 1:length(obj.flightList)
					if ~ismember(obj.perf{j}.Properties.CustomProperties.FlightType, flightType)
						continue
					end
					tmp = obj.perf{j};
					bias(j) = tmp{obj.methodList(i), "windAziNoFiltBias"};
					std(j) = tmp{obj.methodList(i), "windAziNoFiltStd"};
					w(j) = tmp.Properties.CustomProperties.meanWindHMag;
					refErrBias(j) = tmp{obj.methodList(i), 'refErrBias'};
					refErrStd(j) = tmp{obj.methodList(i), 'refErrStd'};
				end
				
				bias = rmmissing(bias);
				std = rmmissing(std);
				w = rmmissing(w);
				refErrBias = rmmissing(refErrBias);
				refErrStd = rmmissing(refErrStd);

				t = table(w, bias, std,refErrBias,refErrStd);
				t = sortrows(t);

				disp(obj.methodList(i))
                disp("Max bias : " + num2str(max(bias)))
                disp("Mean bias : " + num2str(mean(bias)))
                disp("Max std : " + num2str(max(std)))
                disp("Mean std : " + num2str(mean(std)))

				ax = [ax, nexttile];
				hold on
				title(obj.legMap(obj.methodList(i)))
				xlabel("Ref Mean wind speed [m/s]")
				ylabel("Wind speed [m/s]")
				grid on

				hb = plot(t.w, t.bias,'-o','Color', '#0072BD')
				hstd = plot(t.w, t.bias + t.std, '--', 'Color', '#0072BD')
				plot(t.w, t.bias - t.std, '--', 'Color', '#0072BD')
				patch([t.w; flip(t.w)], [t.bias + t.std; flip(t.bias - t.std)],[0 0.4470 0.7410],'FaceAlpha',0.2, 'EdgeColor','none' )

				hrb = plot(t.w, t.refErrBias,'-o','Color', '#D95319')
				hrstd = plot(t.w, t.refErrBias + t.refErrStd, '--', 'Color', '#D95319')
				plot(t.w, t.refErrBias - t.refErrStd, '--', 'Color', '#D95319')
				patch([t.w; flip(t.w)], [t.refErrBias + t.refErrStd; flip(t.refErrBias - t.refErrStd)],[0.8500 0.3250 0.0980],'FaceAlpha',0.2, 'EdgeColor','none' )
		
				
			end
			linkaxes(ax,'xy')
			lgd = legend([hb, hstd, hrb, hrstd],["Est. Norm of bias", "Est. 1\sigma deviation","Ref. Norm of bias", "Ref. 1\sigma deviation"], 'location', 'layout');
            lgd.Layout.Tile = 6;
            sgtitle(["Horizontal performance over wind speed", "Flight type : " + titleFlightType],'Fontsize',17)
		end

		function plotErrorOverWind_totalVert(obj, flightType)
			if isempty(obj.perf)
				for i = 1:length(obj.flightList)
					obj.perf{i} = obj.singleFlightPerf(obj.flightList(i));
				end
			end



			figure(obj.figIdx)
			obj.figIdx = obj.figIdx + 1;
			clf
			ax = [];
			tiledlayout(3,2)

			titleFlightType = flightType;

			if flightType == "all" 
				flightType = obj.flightTypeList;
			elseif flightType == "Vertical"
				flightType = ["Vertical2ms","Vertical3ms","Vertical4ms","Vertical5ms"];
			end

			for i = 1:length(obj.methodList)
				w = nan(length(obj.flightList),1);
				bias = nan(length(obj.flightList),1);
				std = nan(length(obj.flightList),1);
				refErrBias = nan(length(obj.flightList),1);
                refErrStd = nan(length(obj.flightList),1);

				for j = 1:length(obj.flightList)
					if ~ismember(obj.perf{j}.Properties.CustomProperties.FlightType, flightType)
						continue
					end
					tmp = obj.perf{j};
					bias(j) = tmp{obj.methodList(i), "windVertNoFiltBias"};
					std(j) = tmp{obj.methodList(i), "windVertNoFiltStd"};
					w(j) = tmp.Properties.CustomProperties.meanWindHMag;
					refErrBias(j) = tmp{obj.methodList(i), 'refErrBiasVert'};
					refErrStd(j) = tmp{obj.methodList(i), 'refErrStdVert'};
				end
				
				bias = rmmissing(bias);
				std = rmmissing(std);
				w = rmmissing(w);
				refErrBias = rmmissing(refErrBias);
				refErrStd = rmmissing(refErrStd);

				t = table(w, bias, std, refErrBias, refErrStd);
				t = sortrows(t);

				

				ax = [ax, nexttile];
				hold on
				title(obj.legMap(obj.methodList(i)))
				xlabel("Mean wind speed [m/s]")
				ylabel("Wind speed [m/s]")
				grid on

				hb = plot(t.w, t.bias,'-o','Color', '#0072BD')
				hstd = plot(t.w, t.bias + t.std, '--', 'Color', '#0072BD')
				plot(t.w, t.bias - t.std, '--', 'Color', '#0072BD')
				patch([t.w; flip(t.w)], [t.bias + t.std; flip(t.bias - t.std)],[0 0.4470 0.7410],'FaceAlpha',0.2, 'EdgeColor','none' )

				hrb = plot(t.w, t.refErrBias,'-o','Color', '#D95319')
				hrstd = plot(t.w, t.refErrBias + t.refErrStd, '--', 'Color', '#D95319')
				plot(t.w, t.refErrBias - t.refErrStd, '--', 'Color', '#D95319')
				patch([t.w; flip(t.w)], [t.refErrBias + t.refErrStd; flip(t.refErrBias - t.refErrStd)],[0.8500 0.3250 0.0980],'FaceAlpha',0.2, 'EdgeColor','none' )
				
			end
			linkaxes(ax,'xy')
			lgd = legend([hb, hstd, hrb, hrstd],["Est. Norm of bias", "Est. 1\sigma deviation","Ref. Norm of bias", "Ref. 1\sigma deviation"], 'location', 'layout');
            lgd.Layout.Tile = 6;
            sgtitle(["Vertical performance over wind speed", "Flight type : " + titleFlightType],'Fontsize',17)
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
				if ismember('rho', obj.data{i}.Properties.VariableNames)
					res(flightIdx, methodIdx) = res(flightIdx, methodIdx) + " rho : " + num2str(obj.data{i}.rho(1), 4);
				end
			end
			t = array2table(res, 'VariableNames', obj.methodList, 'RowNames', obj.flightList);
			disp(t);
		end
	end
end		
