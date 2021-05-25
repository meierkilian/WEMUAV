function para = ParaGen_Eval()
% Generating parameters relevant for estimation

    % Path to input data, should be a .mat file containing a timetable
    % formatted as outputted by the Estimator class.
    % para.inputPath = {...
    %     char(fullfile(".","outData","estimator","FLY139__20210420_093845__20210420_093918_directdynamicmodel.mat")) ...
    %     ,char(fullfile(".","outData","estimator","FLY139__20210420_093845__20210420_093918_garreausimple.mat")) ...
    %     ,char(fullfile(".","outData","estimator","FLY139__20210420_092941__20210420_093711_directdynamicmodel.mat")) ...
    %     ,char(fullfile(".","outData","estimator","FLY139__20210420_092941__20210420_093711_garreausimple.mat")) ...
    %     ,char(fullfile(".","outData","estimator","SIMULATED_directdynamicmodel.mat")) ...
    %     ,char(fullfile(".","outData","estimator","SIMULATED_garreausimple.mat")) ...
    %     };
    %     % ,char(fullfile(".","outData","estimator","FLY139__20210420_093845__20210420_093918_ekf.mat")) ...
    %     % ,char(fullfile(".","outData","estimator","FLY139__20210420_092941__20210420_093711_ekf.mat")) ...
    %     % ,char(fullfile(".","outData","estimator","SIMULATED_ekf.mat")) ...
    
    t = dir(fullfile(".","outData","estimator","*.mat"));
    for i = 1:length(t)
        para.inputPath(i) = string(fullfile(t(i).folder,t(i).name));
    end
    disp("[ParaGen Eval] Nbr of flight to evaluate is " + num2str(length(para.inputPath)));