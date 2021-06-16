classdef PrePro_TOPOAWS
    properties
        para
    end
    
    methods
        function obj = PrePro_TOPOAWS(para)
            obj.para = para;
        end
        
        % Get datastore with proper header
        % INPUT :
        %   filename : path (including file extension) to the file to load
        % OUTPUT :
        %   ds : datastore
        function ds = getDatastore(obj, filename)            
            ds = tabularTextDatastore(filename, 'NumHeaderLines', 0, 'OutputType', 'table');
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
            ds.SelectedVariableNames = cellstr([obj.para.tow, obj.para.gpsLock, obj.para.varOfInterest(validFields)]);
            data = readall(ds);


            % Compute time vector
            gpsLockIdx = find(data.(obj.para.gpsLock),1);
            if obj.para.gpsWeekStart ~= ""
                timespace = obj.para.gpsWeekStart + seconds(data.(obj.para.tow)(gpsLockIdx:end));
            else
                [~, fileName, ~] = fileparts(path);
                timespace = datetime(fileName) + seconds(data.(obj.para.tow)(gpsLockIdx:end));
            end


            % Creating the timetable
            tt = table2timetable(data(gpsLockIdx:end,cellstr(obj.para.varOfInterest(validFields))),'RowTimes',timespace);

            % Creating a map from the header names (as present in the input
            % file) to the "standardised" desiredFields
            headerMap = containers.Map(cellstr(obj.para.varOfInterest(validFields)), desiredFields(validFields));

            % Change timetable header accordingly
            tt.Properties.VariableNames = values(headerMap, tt.Properties.VariableNames);

            % Converting wind direction from cardinal direction to angle 
            windMap = containers.Map({'CIP','RC','N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW'},[0, 0, 0:22.5:359]);
            tmpWindDir = zeros(size(tt.windHDir_0150cm));
            for i = 1:length(tt.windHDir_0150cm) 
                tmpWindDir(i) = windMap(char(tt.windHDir_0150cm(i)));
            end
            tt.windHDir_0150cm = tmpWindDir;
            
            % Perform unit correction
            tt.Variables = tt.Variables * diag(obj.para.unitConv(validFields));
            
            % Remove duplicate times
            uniqueTimes = unique(tt.Time);
            tt = retime(tt,uniqueTimes,'lastvalue');
        end           
    end
end