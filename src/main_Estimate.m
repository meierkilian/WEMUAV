function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    main_ParaGen
    PARA = readstruct(paraPath);
    est = Estimator(PARA.estimator);
    
    tic
    est.doEstimate()
    toc
    
end