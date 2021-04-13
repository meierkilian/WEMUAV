function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    main_ParaGen
    PARA = readstruct(paraPath);
    eval = Eval(PARA.eval);
    
    % TODO : remove this parameter dependence 
    eval.plotValueOverFlight("FLY130");
end