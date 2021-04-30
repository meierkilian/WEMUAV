function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    main_ParaGen
    PARA = readstruct(paraPath);
    eval = Eval(PARA.eval);
    
    % TODO : remove this parameter dependence 
    eval.plotValueOverFlight("FLY139__20210420_093920__20210420_094000");
    eval.plotErrorOverFlight("FLY139__20210420_093920__20210420_094000");
    
    eval.plotValueOverFlight("FLY139__20210420_093000__20210420_093400");
    eval.plotErrorOverFlight("FLY139__20210420_093000__20210420_093400");
end