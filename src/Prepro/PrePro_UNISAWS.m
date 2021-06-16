classdef PrePro_UNISAWS
    % UNISAWS Preprocessing
    properties
        para % preprocessing parameters
    end
    
    methods
        function obj = PrePro_UNISAWS(para)
            % Constructor
            obj.para = para;
        end
        
        function ds = getDatastore(obj, filename)            
            % Get datastore with proper header
            % INPUT :
            %   filename : path (including file extension) to the file to load
            % OUTPUT :
            %   ds : datastore
            ds = tabularTextDatastore(filename, 'NumHeaderLines', 4, 'OutputType', 'timetable');
            ds.VariableNames = obj.para.header;
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