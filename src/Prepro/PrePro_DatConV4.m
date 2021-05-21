classdef PrePro_DatConV4
    properties
        para
    end
    
    methods
        function obj = PrePro_DatConV4(para)
            obj.para = para;
        end
        
        % Get datastore with proper header. Takes care of the fact that
        % the DatCon csv is not rectangular.
        % INPUT :
        %   filename : path (including file extension) to the file to load
        % OUTPUT :
        %   ds : datastore
        function ds = getDatastore(~, filename)
            % Manually getting the header line
            file = fopen(filename,'r');
            headerLine = fgetl(file);
            header = split(headerLine,',');
            fclose(file);
            
            % Creating the datastore. This process ignores the two first
            % lines of the DataCon file since they are of different length
            % (nbr of fields) that the main data body.
            ds = tabularTextDatastore(filename);
            
            % Manually assigning header name.
            ds.VariableNames = header(1:end-2);            
        end
        
        % Get timetable from file with proper time vector. The returned
        % timetable has header from the desiredFields variable.
        % INPUT : 
        %   path : path to file to load
        %   desiredFields : ordered list of standardised field names
        % OUTPUT :
        %   tt : timetable
        function tt = getTimetable(obj, path, desiredFields)
            if any(size(desiredFields) ~= size(obj.para.varOfInterest))
                error("Size of the desiredFields and varOfInterest do not match. Use empty char array ('') has place holder if necessary.")
            end
            
            validFields = ~strcmp(obj.para.varOfInterest, '');

            ds = obj.getDatastore(path);
            
            ds.SelectedVariableNames = cellstr([ ...
                obj.para.UTCyear, ...
                obj.para.UTCmonth, ...
                obj.para.UTCday, ...
                obj.para.UTChour, ...
                obj.para.UTCminute, ...
                obj.para.UTCsec, ...
                obj.para.timeStamp, ...
                obj.para.varOfInterest(validFields) ...
                ]);
            
            data = readall(ds);
            idx = find(data.(obj.para.UTCyear) > 1980,1); % 1980 is start of GPS time and default value for year in log files
            if isempty(idx)
                error("No UTC time lock was found");    
            end
            
            % Creating proper time space vector from GPS time and internal
            % ticks
            offset = (data.(obj.para.timeStamp) - data.(obj.para.timeStamp)(idx))/obj.para.clkFreq;
            timespace = datetime( ...
                data.(obj.para.UTCyear)(idx), ...
                data.(obj.para.UTCmonth)(idx), ...
                data.(obj.para.UTCday)(idx), ...
                data.(obj.para.UTChour)(idx), ...
                data.(obj.para.UTCminute)(idx), ...
                data.(obj.para.UTCsec)(idx) + offset ...
                );                
            
            lastGPSTime = datetime( ...
                data.(obj.para.UTCyear)(end), ...
                data.(obj.para.UTCmonth)(end), ...
                data.(obj.para.UTCday)(end), ...
                data.(obj.para.UTChour)(end), ...
                data.(obj.para.UTCminute)(end), ...
                data.(obj.para.UTCsec)(end) ...
                );      

            if timespace(end) - lastGPSTime > seconds(1)
                warning("[PrePro_DatConV4] Difference between UTC and ticks is : " + string(timespace(end) - lastGPSTime))
            end


            % Creating the timetable
            tt = table2timetable(data(:,cellstr(obj.para.varOfInterest(validFields))),'RowTimes',timespace);

            % Creating a map from the header names (as present in the input
            % file) to the "standardised" desiredFields
            headerMap = containers.Map(cellstr(obj.para.varOfInterest(validFields)), desiredFields(validFields));

            % Change timetable header accordingly
            tt.Properties.VariableNames = values(headerMap, tt.Properties.VariableNames);

            % Perform unit correction
            tt.Variables = tt.Variables * diag(obj.para.unitConv(validFields));
            
            % TODO : cleaner ?  
            tt.windHDir_other = mod(tt.windHDir_other + 180, 360);
        end
        
    end
end
