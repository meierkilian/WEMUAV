function main_PrePro(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    main_ParaGen
    PARA = readstruct(paraPath);
    pp = PrePro(PARA.prepro);
    
    tic
    pp.doPrePro()
    toc
    
end