function main_PrePro(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    % main_ParaGen
    % PARA = readstruct(paraPath);
    pp = PrePro(ParaGen_PrePro());
    
    tic
    pp.doPrePro()
    toc
    
end