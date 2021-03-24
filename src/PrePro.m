classdef PrePro
    properties
        timeSpace
    end
    
    methods
        % Constructor
        function obj = PrePro()
            obj.timeSpace = NaN;
        end
        
        % Load DatCon data into a datastore. Takes care of the fact that
        % the DatCon csv is not rectangular.
        % INPUT :
        %   filename
        function ds = correctDatCon(~, filename)
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
        
    end
end

        