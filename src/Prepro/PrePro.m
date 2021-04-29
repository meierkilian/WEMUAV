classdef PrePro
    properties
        para
    end
    
    methods
        % Constructor
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
            if isempty(char(path))
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
        function totalTT = synch(obj, flightTT, refTT)
            if obj.para.startTime == "" % Check if startTime was not given, if so taking the earliest possible start time.
                start = max(flightTT.Properties.StartTime, refTT.Properties.StartTime);
            else
                start = obj.para.startTime;
            end
            
            if obj.para.endTime == "" % Check if endtime was not given, if so taking the latest possible end time.
                if isempty(refTT) % Check for empty reference because of min/max return empty arrays when given empty arrays.
                    stop = max(flightTT.Properties.RowTimes);
                else
                    stop = min(max(flightTT.Properties.RowTimes), max(refTT.Properties.RowTimes));
                end
            else
                stop = obj.para.endTime;
            end
            
            timeSpace = start:seconds(obj.para.timeRes):stop;
            totalTT = synchronize(flightTT, refTT, timeSpace, 'linear', 'EndValues', NaN);            
        end
        
        % Adds roll pitch and yaw column to timetable base on quaternion column
        % TODO : complete comments
        function tt = addrpy(~, tt)
            if any(ismember("roll", tt.Properties.VariableNames))
                return
            end

            
            eul = euler(quaternion(tt.q1, tt.q2, tt.q3, tt.q4), 'XYZ', 'point');
            tt.roll = eul(:,1);
            tt.pitch = eul(:,2);
            tt.yaw = eul(:,3);

%             tt.roll = atan2(2*(tt.q1.*tt.q2 + tt.q3.*tt.q4), 1 - 2*(tt.q2.^2 + tt.q3.^2));
%             tt.pitch = asin(2*(tt.q1.*tt.q3 - tt.q4.*tt.q2));
%             tt.yaw = atan2(2*(tt.q1.*tt.q4 + tt.q2.*tt.q3), 1 - 2*(tt.q3.^2 + tt.q4.^2));
        end
        
        % Perform preprocessing. Load, synchronise and store reference and
        % flight data.
        function doPrePro(obj)
            if any(size(obj.para.flightInput.path) ~= size(obj.para.refInput.path))
                error("Number of flight data and reference data should be the same, if no reference is available specify '' (empty char vector)");
            end
            
            % Iterating over all flight-ref data pair
            for i = 1:length(obj.para.flightInput.path)
                disp("Processing flight " + obj.para.flightInput.path(i))
                
                flightTT = obj.getTimetable(obj.para.flightInput.path(i), obj.para.flightInput.type);
                refTT = obj.getTimetable(obj.para.refInput.path(i), obj.para.refInput.type);
                totalTT = obj.synch(flightTT, refTT);

                totalTT = obj.addrpy(totalTT);
            
                if obj.para.output.type == "default"
                    [~, outName, ~] = fileparts(obj.para.flightInput.path(i));
                    outName = outName + "__" + datestr(totalTT.Time(1), 'yyyymmdd_HHMMSS') + "__" + datestr(totalTT.Time(end), 'yyyymmdd_HHMMSS');
                    save(fullfile(obj.para.output.path, outName + ".mat"), 'totalTT', '-mat')
                end
            end                
        end        
    end
end

        