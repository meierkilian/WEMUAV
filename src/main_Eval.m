function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    % main_ParaGen
    % PARA = readstruct(paraPath);
    eval = Eval(ParaGen_Eval());
    
    % eval.dispAllMagErr();
 
    % eval.plotValueOverFlight("FLY167__20210503_141451__Hover");
    % eval.plotErrorOverFlight("FLY167__20210503_141451__Hover");

    eval.plotValueOverFlight("FLY139__20210420_093845__Square");
    eval.plotErrorOverFlight("FLY139__20210420_093845__Square");
    
    % eval.plotValueOverFlight("SIMULATED");
    % eval.plotErrorOverFlight("SIMULATED");
end