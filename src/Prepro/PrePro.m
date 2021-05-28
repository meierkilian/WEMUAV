classdef PrePro
    properties
        para
    end
    
    methods
        % Constructor
        % INPUT : 
        %   para : parameter set as a structure
        % OUTPUT : 
        %   obj : constructed object
        function obj = PrePro(para)
            obj.para = para;
        end
        
        % Get timetable from a file with given type
        % INPUT :
        %   path : path to data
        %   type : type of data contained in file
        % OUTPUT : 
        %   tt : timetable, if path is empty then tt is an empty timetable
        function tt = getTimetable(obj, path, type)
            % Checks for empty path
            if ~isfile(path) && ~isfolder(path)
                tt = timetable();
                return
            end
            
            % Instanciates adapted preprocessor
            if type == "datconv4"
                pp = PrePro_DatConV4(obj.para.datconv4);
            elseif type == "datconv3"
                pp = PrePro_DatConV3(obj.para.datconv3);
            elseif type == "motus"
                pp = PrePro_MoTUS(obj.para.motus);
            elseif type == "unisaws"
                pp = PrePro_UNISAWS(obj.para.unisaws);
            elseif type == "topoaws"
                pp = PrePro_TOPOAWS(obj.para.topoaws);
            else
                error("Unknown data type : " + type);
            end
            
            tt = pp.getTimetable(path, obj.para.output.field);
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
        function totalTT = synch(obj, flightTT, refTT, refMeteoTT, start, stop)
            start = datetime(start);
            stop = datetime(stop);
            if isnat(start) % Check if startTime was not given, if so taking the earliest possible start time.
                start = max([flightTT.Properties.StartTime, refTT.Properties.StartTime, refMeteoTT.Properties.StartTime],[],'omitnat');
            end
            
            if isnat(stop) % Check if endtime was not given, if so taking the latest possible end time.
                if isempty(refTT) % Check for empty reference because of min/max return empty arrays when given empty arrays.
                    stop = max(flightTT.Properties.RowTimes);
                else
                    stop = min([max(flightTT.Properties.RowTimes), max(refTT.Properties.RowTimes), max(refMeteoTT.Properties.RowTimes)]);
                end
            end
            
            timeSpace = start:seconds(obj.para.timeRes):stop;
            totalTT = synchronize(flightTT, refTT, refMeteoTT, timeSpace, 'linear', 'EndValues', NaN);            
        end
        
        % Adds roll pitch and yaw column to timetable base on quaternion columns
        % INPUT :
        %   tt : timetable containing quaternion columns q1, q2, q3 and q4
        % OUPUT :
        %   tt : same timetable as input with added roll, pitch and yaw columns
        function tt = addrpy(~, tt)
            if any(ismember("roll", tt.Properties.VariableNames))
                warning("[PrePro] Data seems to already have euleur angle data. Aborting computing from quaternion.")
                return
            end

            eul = euler(quaternion(tt.q1, tt.q2, tt.q3, tt.q4), 'XYZ', 'point');
            tt.roll = eul(:,1);
            tt.pitch = eul(:,2);
            tt.yaw = eul(:,3);
        end
        
        % Performs preprocessing. Load, synchronise and store reference and
        % flight data.
        function doPrePro(obj)
            if any(size(obj.para.flightInput.path) ~= size(obj.para.refInput.path))
                error("Number of flight data and reference data should be the same, if no reference is available specify '' (empty char vector)");
            end
            
            % Stores the path of the current flight and references
            % Avoids multiple loading of the same files
            currFlightPath = "";
            currRefPath = "";
            currRefMeteoPath = "";
            flightTT = timetable();
            refTT = timetable();
            refMeteoTT = timetable();

            % Iterating over all flight-ref data pair
            for i = 1:length(obj.para.flightInput.path)
                disp("Processing flight " + obj.para.flightInput.path(i))
                
                if currRefMeteoPath ~= obj.para.refMeteoInput.path(i)
                    currRefMeteoPath = obj.para.refMeteoInput.path(i);
                    refMeteoTT = obj.getTimetable(obj.para.refMeteoInput.path(i), obj.para.refMeteoInput.type);
                end
                if currFlightPath ~= obj.para.flightInput.path(i)
                    currFlightPath = obj.para.flightInput.path(i);
                    flightTT = obj.getTimetable(obj.para.flightInput.path(i), obj.para.flightInput.type);
                end
                if currRefPath ~= obj.para.refInput.path(i)
                    currRefPath = obj.para.refInput.path(i);
                    refTT = obj.getTimetable(obj.para.refInput.path(i), obj.para.refInput.type);
                end

                totalTT = obj.synch(flightTT, refTT, refMeteoTT, obj.para.startTime(i), obj.para.endTime(i));

                totalTT = obj.addrpy(totalTT);

                totalTT = addprop(totalTT, {'ID','FlightName','FlightType'}, {'table', 'table', 'table'});
                totalTT.Properties.CustomProperties.ID = obj.para.t.ID(obj.para.selectedIdx(i));
                totalTT.Properties.CustomProperties.FlightName = obj.para.t.FLIGHT(obj.para.selectedIdx(i)) + "__" + datestr(totalTT.Time(1), 'yyyymmdd_HHMMSS') + "__" + obj.para.t.FlightType(obj.para.selectedIdx(i));
                totalTT.Properties.CustomProperties.FlightType = string(obj.para.t.FlightType{obj.para.selectedIdx(i)});
            
                save(fullfile(obj.para.output.path, totalTT.Properties.CustomProperties.FlightName + ".mat"), 'totalTT', '-mat')
            end                
        end        
    end
end

        