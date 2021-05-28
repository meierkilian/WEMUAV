function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    % main_ParaGen
    % PARA = readstruct(paraPath);
    eval = Eval(ParaGen_Eval());
    
    eval.dispAllMagErr();
 
    eval.plotValueOverFlight("FLY167__20210503_141451__Hover");
    eval.plotErrorOverFlight("FLY167__20210503_141451__Hover");

    % eval.plotValueOverFlight("FLY139__20210420_093845__20210420_093918");
    % eval.plotErrorOverFlight("FLY139__20210420_093845__20210420_093918");
    
    % eval.plotValueOverFlight("FLY139__20210420_092941__20210420_093711");
    % eval.plotErrorOverFlight("FLY139__20210420_092941__20210420_093711");
    

    % eval.plotValueOverFlight("SIMULATED");
    % eval.plotErrorOverFlight("SIMULATED");
end