function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    % main_ParaGen
    % PARA = readstruct(paraPath);
    eval = Eval(ParaGen_Eval());
    
    eval.dispAllMagErr();
 
    % eval.plotValueOverFlight("FLY167__20210503_141433__Hover");
    % % eval.plotErrorOverFlight("FLY167__20210503_141433__Hover");

    % eval.plotValueOverFlight("FLY172__20210525_111835__Hover");
    % % eval.plotErrorOverFlight("FLY172__20210525_111835__Hover");
    
    % eval.plotValueOverFlight("FLY178__20210603_061155__Hover_wols");
    % eval.plotValueOverFlight("FLY178__20210603_061155__Hover_wls");
    % % eval.plotErrorOverFlight("FLY178__20210603_061155__Hover");
end