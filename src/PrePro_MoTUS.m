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
           
        
        % Get timetable with proper timevector
        % INPUT : 
        %   ds : datastore
        % OUTPUT :
        %   tt : timetable
        function tt = getTimetable(obj, path)
            ds = obj.getDatastore(path);
            ds.SelectedVariableNames = obj.para.varOfInterest;
%             data = readall(ds);
            tt = timetable();
            warning("createMotusTimetable not implemented yet")
        end           
    end
end
