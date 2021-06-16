classdef PrePro_DatConV3
    % DatConV3 preprocessing
    properties
        para % preprocessing parameters
    end
    
    methods
        function obj = PrePro_DatConV3(para)
            % Constructor

            obj.para = para;
            warning("[PrePro DatConV3] Some parameters where not validate for datconV3 use with caution. In particular check clkFreq and data unitConv!")
        end
        
        function ds = getDatastore(~, filename)
            % Get datastore with proper header. Takes care of the fact that
            % the DatCon csv is not rectangular.
            % INPUT :
            %   filename : path (including file extension) to the file to load
            % OUTPUT :
            %   ds : datastore

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

            ds = obj.getDatastore(path);

            validFields = ~strcmp(obj.para.varOfInterest, '');
            
            ds.SelectedVariableNames = cellstr([ ...
                obj.para.UTCdatetimeString, ...
                obj.para.timeStamp, ...
                obj.para.varOfInterest(validFields) ...
                ]);
            ds.SelectedFormats{1} = '%s'; % Enforces to parse GPS time string as a string (useful when empty data the start)
            
            
            data = readall(ds);
            timespace = datetime(data.(obj.para.UTCdatetimeString),'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z');
            idx = find(year(timespace) > 1980,1); % 1980 is start of GPS time and default value for year in log files
            if isempty(idx)
                error("No UTC time lock was found");    
            end
            
            % Creating proper time space vector from GPS time and internal
            % ticks
            offset = data.(obj.para.timeStamp) - data.(obj.para.timeStamp)(idx);
            timespace = timespace(idx) + seconds(offset);                
            
            % Creating the timetable
            tt = table2timetable(data(:,cellstr(obj.para.varOfInterest(validFields))),'RowTimes',timespace);

            % Creating a map from the header names (as present in the input
            % file) to the "standardised" desiredFields
            headerMap = containers.Map(cellstr(obj.para.varOfInterest(validFields)), desiredFields(validFields));

            % Change timetable header accordingly
            tt.Properties.VariableNames = values(headerMap, tt.Properties.VariableNames);

            % Perform unit correction
            tt.Variables = tt.Variables * diag(obj.para.unitConv(validFields));
        end
    end
end
