classdef PrePro_MoTUS
    % MoTUS preprocessing 
    properties
        para % preprocessing parameters
    end
    
    methods
        function obj = PrePro_MoTUS(para)
            % Constructor
            obj.para = para;
        end
        
        function [ds, suffix] = getDatastore(obj, filename)
            % Get datastore with proper header
            % INPUT :
            %   filename : path (including file extension) to the file to load
            % OUTPUT :
            %   ds : datastore

            ds = tabularTextDatastore(filename, 'NumHeaderLines', 0, ...
                                                'OutputType', 'timetable', ...
                                                'ReadSize', 1);
            ds.VariableNames = obj.para.singleSensHeader;
            data = read(ds);
            portName = data.port;

            portMap = containers.Map(obj.para.ports, obj.para.anemAlti);
            suffix = sprintf("_%04dcm",portMap(portName{:})*100);

            ds.VariableNames = cellstr(ds.VariableNames + suffix);
        end
           
        
        function tt = getTimetable(obj, path, desiredFields)
            % Get timetable from file with proper time vector. The returned
            % timetable has header from the desiredFields variable.
            % INPUT : 
            %   path : path to file to load
            %   desiredFields : ordered list of standardised field names
            % OUTPUT :
            %   tt : timetable
            
            if any(size(desiredFields) ~= size(obj.para.varOfInterest))
                error("Size of the desiredFields and varOfInterest do not match. Use empty char array ('') has place holder if necessary.")
            end

            % Getting all available MoTUS sensor files in folder
            files = dir(fullfile(path, "*" + obj.para.dataFileFormatExtension));

            tt = timetable();

            % For each file, load data and create a timetable
            for i = 1:length(files)
                [ds, suffix] = obj.getDatastore(fullfile(string(files(i).folder), string(files(i).name)));
                
                % Field is valid if not '' and in the header of ds
                validFields = ismember(obj.para.varOfInterest, ds.VariableNames);
                
                ds.SelectedVariableNames = cellstr([obj.para.varOfInterest(validFields), obj.para.UTCdatetimeString + suffix]);
                ttTmp = readall(ds);
                
                % Correcting time vector
                [count, ~] = groupcounts(ttTmp.(obj.para.UTCdatetimeString + suffix));
                idx = [0; cumsum(count)];
                corr = zeros(size(ttTmp.(obj.para.UTCdatetimeString + suffix)));

                for j = 1:length(count) 
                    tmp = linspace(0, 1, count(j) + 1);
                    corr(idx(j) + 1 : idx(j+1)) = tmp(1:count(j));
                end
                
                
                ttTmp.(obj.para.UTCdatetimeString + suffix) = ttTmp.(obj.para.UTCdatetimeString + suffix) + seconds(corr) +  hours(obj.para.local2UTC);
                
                % Creating a map from the header names (as present in the input
                % file) to the "standardised" desiredFields
                headerMap = containers.Map(cellstr(obj.para.varOfInterest(validFields)), desiredFields(validFields));

                % Change timetable header accordingly
                ttTmp.Properties.VariableNames = values(headerMap, ttTmp.Properties.VariableNames);
                
                % Perform unit correction
                ttTmp.Variables = ttTmp.Variables * diag(obj.para.unitConv(validFields));                
                % Removes invalid lines, caused by motus line format
                % changing when windHMag < 0.05 
                [ttTmp, indicator] = rmmissing(ttTmp);
                nbrInvalidLine = sum(indicator);
                if nbrInvalidLine > 0
                    warning("[PrePro_MoTUS] Removed invalid data, nbr line removed : " + num2str(nbrInvalidLine))
                end                   
                
                tt = synchronize(tt, ttTmp);
            end
        end           
    end
end
