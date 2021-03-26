% This script generates a XML file containing all parameters needed for
% running all three main scripts. Storing parameters in an external XML
% file allows for modification of script parameters without any need to
% modify MATLAB scripts (useful in case of standalone compilation).

clear para

% datetime of start time, if "" (empty string) then start is set at the first data point.
para.prepro.startTime = datetime(2021,03,22,14,05,00); 
% para.prepro.startTime = ""; 

% datetime of end time, if "" (empty string) then end is set at the last data point.
para.prepro.endTime = datetime(2021,03,22,14,10,00); 
% para.prepro.endTime = ""; 

% time resolution at which the data is resampled, i.e. duration in [s]
% between two samples.
para.prepro.timeRes = 0.05; % 20 Hz

% path to reference data can be a vector of paths, must match size of
% flightInputpath
para.prepro.refInput.path = {...
    '' ...
%     ,''
    };

% type of reference (describes the file formatting), available types are:
% {"default",...} TODO
para.prepro.refInput.type = 'default';

% path to flight data, can be a vector of paths, must match size of
% refInputpath
para.prepro.flightInput.path = {...
    char(fullfile("C:","Users","Kilian","Documents","EPFL","PDM","Data","topophantom1","20210322","FLY117.csv")) ...
%     ,char(fullfile("C:","Users","Kilian","Documents","EPFL","PDM","Data","topophantom1","20210322","FLY117_10HZ.csv")) ...
    };

% type of reference (describes the file formatting), available types are:
% {'default','datcon'...} TODO
para.prepro.flightInput.type = 'default';

% path to output folder
para.prepro.output.path = fullfile('.','dev','outData');

% type of output (describes the file formatting), available types are:
% {'default',...} TODO
para.prepro.output.type = 'default';

% DatCon date and time field name
para.prepro.datcon.UTCyear = 'gps_utc_data_gps_year_D';
para.prepro.datcon.UTCmonth = 'gps_utc_data_gps_month_D';
para.prepro.datcon.UTCday = 'gps_utc_data_gps_day_D';
para.prepro.datcon.UTChour = 'gps_utc_data_gps_hour_D';
para.prepro.datcon.UTCminute = 'gps_utc_data_gps_minute_D';
para.prepro.datcon.UTCsec = 'gps_utc_data_gps_sec_D';
para.prepro.datcon.timeStamp = 'Clock_offsetTime';

% DatCon variable of interest, i.e. that will be stored in the output file
para.prepro.datcon.varOfInterest = {...
    'IMU_ATTI_0_long0_D',...
    'IMU_ATTI_0_lati0_D'...
    };
    



writestruct(para, fullfile('.','para','default.xml'));




