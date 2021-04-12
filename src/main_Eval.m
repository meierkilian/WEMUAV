function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    main_ParaGen
    PARA = readstruct(paraPath);
    eval = Eval(PARA.eval);
    
    eval.plotValueOverFlight("2020-06-03_FLY113");
end