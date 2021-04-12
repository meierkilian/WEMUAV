% This script generates a XML file containing all parameters needed for
% running all three main scripts. Storing parameters in an external XML
% file allows for modification of script parameters without any need to
% modify MATLAB scripts (useful in case of standalone compilation).

clear para

para.prepro = ParaGen_PrePro();
para.estimator = ParaGen_Estimator(); 
para.eval = ParaGen_Eval();   

% --------------------------------------------------------- %
% Saving parameter
writestruct(para, fullfile('.','para','default.xml'));