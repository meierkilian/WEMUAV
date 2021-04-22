function para = ParaGen_Eval()
% Generating parameters relevant for estimation

    % Path to input data, should be a .mat file containing a timetable
    % formatted as outputted by the Estimator class.
    para.inputPath = {...
        char(fullfile(".","outData","estimator","FLY139_garreausimple.mat")) ...
        };
    