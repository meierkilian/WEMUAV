classdef PrePro_DatCon
    properties
        para
    end
    
    methods
        function obj = PrePro_DatCon(para)
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
        
        % Get timetable from DatCon datastore with proper time vector
        % INPUT : 
        %   ds : datastore
        % OUTPUT :
        %   tt : timetable
        function tt = getTimetable(obj, path)
            ds = obj.getDatastore(path);
            
            ds.SelectedVariableNames = cellstr([ ...
                obj.para.UTCyear, ...
                obj.para.UTCmonth, ...
                obj.para.UTCday, ...
                obj.para.UTChour, ...
                obj.para.UTCminute, ...
                obj.para.UTCsec, ...
                obj.para.timeStamp, ...
                obj.para.varOfInterest ...
                ]);
            
            data = readall(ds);
            idx = find(data.(obj.para.UTCyear) > 1980,1); % 1980 is start of GPS time and default value for year in log files
            if isempty(idx)
                error("No UTC time lock was found");    
            end
            
            % Creating proper time space vector from GPS time and internal
            % ticks
            offset = data.(obj.para.timeStamp) - data.(obj.para.timeStamp)(idx);
            timespace = datetime( ...
                data.(obj.para.UTCyear)(idx), ...
                data.(obj.para.UTCmonth)(idx), ...
                data.(obj.para.UTCday)(idx), ...
                data.(obj.para.UTChour)(idx), ...
                data.(obj.para.UTCminute)(idx), ...
                data.(obj.para.UTCsec)(idx) + offset ...
                );                
            
            tt = table2timetable(data(:,cellstr(obj.para.varOfInterest)),'RowTimes',timespace);            
        end
        
    end
end
