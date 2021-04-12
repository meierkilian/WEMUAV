classdef PrePro_UNISAWS
    properties
        para
    end
    
    methods
        function obj = PrePro_UNISAWS(para)
            obj.para = para;
        end
        
        % Get datastore with proper header
        % INPUT :
        %   filename : path (including file extension) to the file to load
        % OUTPUT :
        %   ds : datastore
        function ds = getDatastore(obj, filename)            
            ds = tabularTextDatastore(filename, 'NumHeaderLines', 4, 'OutputType', 'timetable');
            ds.VariableNames = obj.para.header;
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
            ds.SelectedVariableNames = cellstr([obj.para.timeStamp, obj.para.varOfInterest(validFields)]);
            tt = readall(ds);

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