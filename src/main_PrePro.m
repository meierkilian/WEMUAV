function main_PrePro(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    PARA = readstruct(paraPath);
    
    % Correcting DatCon output
    fn = 'C:\Users\Kilian\Documents\EPFL\PDM\Data\topophantom1\20210322\FLY117.csv';
    pp = PrePro();
    pp.correctDatCon(fn);
    
    
end