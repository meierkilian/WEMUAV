classdef PrePro_MoTUS
    properties
        para
    end
    
    methods
        function obj = PrePro_MoTUS(para)
            obj.para = para;
        end
        
        % Get datastore with proper header
        % INPUT :
        %   filename : path (including file extension) to the file to load
        % OUTPUT :
        %   ds : datastore
        function ds = getDatastore(obj, filename)
            ds = tabularTextDatastore(filename);
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

            % ds = obj.getDatastore(path);
            % ds.SelectedVariableNames = obj.para.varOfInterest(validFields);
%             data = readall(ds);
            tt = timetable();
            warning("createMotusTimetable not implemented yet")
        end           
    end
end
