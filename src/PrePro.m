classdef PrePro
    properties
        para
    end
    
    methods
        % Constructor
        function obj = PrePro(para)
            obj.para = para;
        end
        
        % Load DatCon data into a datastore. Takes care of the fact that
        % the DatCon csv is not rectangular.
        % INPUT :
        %   filename : path (including file extension) to the file to load
        % OUTPUT :
        %   ds : datastore co
        function ds = loadDatCon(~, filename)
            % Manually getting the header line
            file = fopen(filename,'r');
            headerLine = fgetl(file);
            header = split(headerLine,',');
            
            % Creating the datastore. This process ignores the two first
            % lines of the DataCon file since they are of different length
            % (nbr of fields) that the main data body.
            ds = tabularTextDatastore(filename);
            
            % Manually assigning header name.
            ds.VariableNames = header(1:end-2);            
        end
        
        % Get datetime vector from datastore
        % INPUT : 
        %   ds : datastore
        % OUTPUT :
        %   timespace : array of datetime that can be used to create a
        %   timetable
        function timespace = getDatConDatetime(obj, ds)
            ds.SelectedVariableNames = cellstr([ ...
                obj.para.prepro.datcon.UTCyear, ...
                obj.para.prepro.datcon.UTCmonth, ...
                obj.para.prepro.datcon.UTCday, ...
                obj.para.prepro.datcon.UTChour, ...
                obj.para.prepro.datcon.UTCminute, ...
                obj.para.prepro.datcon.UTCsec, ...
                obj.para.prepro.datcon.timeStamp
                ]);
            
            data = readall(ds);
            idx = find(data.(obj.para.prepro.datcon.UTCyear) > 1980,1); % 1980 is start of GPS time and default value for year in log files
            if isempty(idx)
                error("No UTC time lock was found");    
            end
            
            offset = data.(obj.para.prepro.datcon.timeStamp) - data.(obj.para.prepro.datcon.timeStamp)(idx);
            timespace = datetime( ...
                data.(obj.para.prepro.datcon.UTCyear)(idx), ...
                data.(obj.para.prepro.datcon.UTCmonth)(idx), ...
                data.(obj.para.prepro.datcon.UTCday)(idx), ...
                data.(obj.para.prepro.datcon.UTChour)(idx), ...
                data.(obj.para.prepro.datcon.UTCminute)(idx), ...
                data.(obj.para.prepro.datcon.UTCsec)(idx) + offset ...
                );                
        end
        
        % Create timetable DatCon flight data
        % INPUT :
        %   path : path to data
        % OUTPUT :
        %   tt : timetable containing the data of the variable of interest
        function tt = createDatConData(obj, path)
            ds = obj.loadDatCon(path);
            
            ts = obj.getDatConDatetime(ds);
            
            ds.SelectedVariableNames = cellstr(obj.para.prepro.datcon.varOfInterest);
            data = readall(ds);
            tt = table2timetable(data,'RowTimes',ts);            
        end
        
        % Create timetable containing total flight data
        % INPUT :
        %   path : path to data
        % OUTPUT : 
        %   tt : flight data 
        function tt = createFlightData(obj, path)
            if obj.para.prepro.flightInput.type == "datcon" || obj.para.prepro.flightInput.type == "default"
                tt = obj.createDatConData(path);
            else
                error("Unknown flight input type");
            end
        end
        
        % Create timetable containing total reference data
        % INPUT :
        %   path : path to data
        % OUTPUT :
        %   tt : reference data
        function tt = creatRefData(obj, path)
            if obj.para.prepro.refInput.type == "default"
                tt = timetable();
            else
                error("Unknown flight input type");
            end
        end
        
        % Synchronise and select desired timespan in flight and ref data.
        % Timespan and sample rate is defined by parameters. Interpolation
        % is linear. 
        % INPUT :
        %   flightTT : flight data timetable
        %   refTT : reference data timetable, can be an empty timetable if
        %           no reference data is available.
        % OUTPUT :
        %   totalTT : resulting total 
        function totalTT = synch(obj, flightTT, refTT)
            if obj.para.prepro.startTime == "" % Check if startTime was not given, if so taking the earliest possible start time.
                start = max(flightTT.Properties.StartTime, refTT.Properties.StartTime);
            else
                start = obj.para.prepro.startTime;
            end
            
            if obj.para.prepro.endTime == "" % Check if endtime was not given, if so taking the latest possible end time.
                if isempty(refTT) % Check for empty reference because of min/max return empty arrays when given empty arrays.
                    stop = max(flightTT.Properties.RowTimes);
                else
                    stop = min(max(flightTT.Properties.RowTimes), max(refTT.Properties.RowTimes));
                end
            else
                stop = obj.para.prepro.endTime;
            end
            
            timeSpace = start:seconds(obj.para.prepro.timeRes):stop;
            totalTT = synchronize(flightTT, refTT, timeSpace, 'linear');            
        end
        
        
        % Perform preprocessing. Load, synchronise and store reference and
        % flight data.
        function doPrePro(obj)
            if any(size(obj.para.prepro.flightInput.path) ~= size(obj.para.prepro.refInput.path))
                error("Number of flight data and reference data should be the same, if no reference is available specify '' (empty char vector)");
            end
            
            % Iterating over all flight-ref data pair
            for i = 1:length(obj.para.prepro.flightInput.path)
                disp("Processing flight " + obj.para.prepro.flightInput.path(i))
                
                flightTT = obj.createFlightData(obj.para.prepro.flightInput.path(i));
                refTT = obj.creatRefData(obj.para.prepro.refInput.path(i));
                totalTT = obj.synch(flightTT, refTT);
            
                if obj.para.prepro.output.type == "default"
                    [~, outName, ~] = fileparts(obj.para.prepro.flightInput.path(i));
                    save(fullfile(obj.para.prepro.output.path, outName + ".mat"), 'totalTT', '-mat')
                end
            end                
        end        
    end
end

        