function para = ParaGen_Estimator()
% Generating parameters relevant for estimation

    % Path to input data, should be a .mat file containing a timetable
    % formatted as outputted by the PrePro class.
    para.inputPath = {...
        char(fullfile("C:","Users","Kilian","Documents","EPFL","PDM","SW","WEMUAV","dev","outData","2020-07-18_FLY122_profile.mat")) ...
        };
    
    % Method to be used for estimation. Each method of this list is used on
    % each file in the inputPath. Available methods are
    % {'garreausimple',...} TODO
    para.method = {...
        'garreausimple' ...
        };