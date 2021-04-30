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
    para.inputPath = {...
        char(fullfile(".","outData","prepro","FLY139__20210420_093920__20210420_094000.mat")) ...
        ,char(fullfile(".","outData","prepro","FLY139__20210420_093000__20210420_093400.mat")) ...
        };
    
    % Method to be used for estimation. Each method of this list is used on
    % each file in the inputPath. Available methods are
    % {'garreausimple',...}
    % TODO : update description
    para.method = {...
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

    

