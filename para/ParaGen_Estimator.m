function para = ParaGen_Estimator()
% Generating parameters relevant for estimation

    % DEFINING CONSTANTS
    % drone mass [kg]
    para.cst.m = 1.391;

    % gravitational acceleration [m/s^2]
    para.cst.g = 9.81;

    % air densisty [kg/m^3]
    para.cst.rho = 1.225;


    % Path to input data, should be a .mat file containing a timetable
    % formatted as outputted by the PrePro class.
    % para.inputPath = {...
    %     char(fullfile(".","outData","prepro","FLY139__20210420_093845__20210420_093918.mat")) ...
    %     ,char(fullfile(".","outData","prepro","FLY139__20210420_092941__20210420_093711.mat")) ...
    %     ,char(fullfile(".","outData","prepro","SIMULATED.mat")) ...
    %     };

    t = dir(fullfile(".","outData","prepro","*.mat"));
    for i = 1:length(t)
        para.inputPath(i) = string(fullfile(t(i).folder,t(i).name));
    end
    disp("[ParaGen Estimator] Nbr of flight to estimate is " + num2str(length(para.inputPath)));

    
    % Method to be used for estimation. Each method of this list is used on
    % each file in the inputPath. Available methods are
    % {'garreausimple',...}
    % TODO : update description
    para.method = {...
        % 'ekf' ...
        'directdynamicmodel' ...
        ,'garreausimple' ...
        };

    % Path to output folder
    para.outputPath = fullfile(".", "outData", "estimator");


    % Including constants in the garreausimple parameters
    para.garreausimple.cst = para.cst;

    % TODO : (is a pressure, but of what on what ? Related to wind tunnel tests) [lb/m^2]
    para.garreausimple.cst.qnasa = 0.48/0.092903;

    % Path to Russel (NASA) drag data
    para.garreausimple.dragDataPath.F = fullfile("C:","Users","Kilian","Documents","EPFL","PDM","SW","EstArthurGarreau","1_DATA","Drag_Russel","F.txt");
    para.garreausimple.dragDataPath.T = fullfile("C:","Users","Kilian","Documents","EPFL","PDM","SW","EstArthurGarreau","1_DATA","Drag_Russel","T.txt");

    % garreausimple regression parameter 
    para.garreausimple.reg.alpha1 = 1113.2;
    para.garreausimple.reg.alpha2 = 501.2032;
    para.garreausimple.reg.beta = -36.2747;
    para.garreausimple.reg.cut = 0.091;


    % Including constants in the directdynamicmodel parameters
    para.directdynamicmodel.cst = para.cst;


    % Including constants in the directdynamicmodel parameters
    para.ekf.cst = para.cst;

    % Initial guess and covariance of values for acPara and ws
    % para.ekf.init.augState.value.b = -1.159e-7;
    para.ekf.init.augState.value.b = 1.965e-5/1.784;
    para.ekf.init.augState.std.b = 1e-7;
    para.ekf.init.augState.value.Cxx = 0.455;
    para.ekf.init.augState.std.Cxx = 1e-2;
    para.ekf.init.augState.value.Cyy = 0.455;
    para.ekf.init.augState.std.Cyy = 1e-2;
    para.ekf.init.augState.value.Czz = 0.4427;
    para.ekf.init.augState.std.Czz = 1e-1;
    para.ekf.init.ws.std = 10;
    para.ekf.init.ac.std = 10;



    

