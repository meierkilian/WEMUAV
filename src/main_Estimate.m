function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    % main_ParaGen
    % PARA = readstruct(paraPath);
    est = Estimator(ParaGen_Estimator());
    
    tic
    est.doEstimate()
    toc
    
end