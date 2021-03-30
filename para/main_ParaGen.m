% This script generates a XML file containing all parameters needed for
% running all three main scripts. Storing parameters in an external XML
% file allows for modification of script parameters without any need to
% modify MATLAB scripts (useful in case of standalone compilation).

clear para

% datetime of start time, if "" (empty string) then start is set at the first data point.
% para.prepro.startTime = datetime(2021,03,22,14,05,00); 
para.prepro.startTime = datetime(2020,07,18,16,00,00); 
% para.prepro.startTime = ""; 

% datetime of end time, if "" (empty string) then end is set at the last data point.
% para.prepro.endTime = datetime(2021,03,22,14,10,00); 
para.prepro.endTime = datetime(2020,07,18,16,10,00); 
% para.prepro.endTime = ""; 

% time resolution at which the data is resampled, i.e. duration in [s]
% between two samples.
para.prepro.timeRes = 0.05; % 20 Hz

% path to reference data can be a vector of paths, must match size of
% flightInputpath
para.prepro.refInput.path = {...
    char(fullfile("C:","Users","Kilian","Documents","EPFL","PDM","SW","EstArthurGarreau","1_DATA","Anemo","2020.07.18 23.59 Adventdalen_Sec.dat")) ...
%     ,''
    };

% type of reference (describes the file formatting), available types are:
% {"motus","unisaws",...} TODO
para.prepro.refInput.type = 'unisaws';

% path to flight data, can be a vector of paths, must match size of
% refInputpath
para.prepro.flightInput.path = {...
    char(fullfile("C:","Users","Kilian","Documents","EPFL","PDM","SW","EstArthurGarreau","1_DATA","Phantom","2020-07-18_FLY122_profile.csv")) ...
%     char(fullfile("C:","Users","Kilian","Documents","EPFL","PDM","Data","topophantom1","20210322","FLY117_10HZ.csv")) ...
%     ,char(fullfile("C:","Users","Kilian","Documents","EPFL","PDM","Data","topophantom1","20210322","FLY117_10HZ.csv")) ...
    };

% type of reference (describes the file formatting), available types are:
% {'datconv3', 'datconv4'...} TODO
para.prepro.flightInput.type = 'datconv3';

% path to output folder
para.prepro.output.path = fullfile('.','dev','outData');

% type of output (describes the file formatting), available types are:
% {'default',...} TODO
para.prepro.output.type = 'default';

% datconv4 date and time field name
para.prepro.datconv4.UTCyear = 'gps_utc_data_gps_year_D';
para.prepro.datconv4.UTCmonth = 'gps_utc_data_gps_month_D';
para.prepro.datconv4.UTCday = 'gps_utc_data_gps_day_D';
para.prepro.datconv4.UTChour = 'gps_utc_data_gps_hour_D';
para.prepro.datconv4.UTCminute = 'gps_utc_data_gps_minute_D';
para.prepro.datconv4.UTCsec = 'gps_utc_data_gps_sec_D';
para.prepro.datconv4.timeStamp = 'Clock_offsetTime';

% datconv4 variable of interest, i.e. that will be stored in the output file
para.prepro.datconv4.varOfInterest = {...
    'IMU_ATTI_0_long0_D',...
    'IMU_ATTI_0_lati0_D'...
    };

% datconv3 date and time field name
para.prepro.datconv3.UTCdatetimeString = 'GPS_dateTimeStamp';
para.prepro.datconv3.timeStamp = 'offsetTime';

% datconv3 variable of interest, i.e. that will be stored in the output
% file
para.prepro.datconv3.varOfInterest = {...
    'IMU_ATTI_0__Longitude',...
    'IMU_ATTI_0__Latitude'...
    }; 

% MoTUS data header 
para.prepro.motus.header = {'ID','HorizDir','HorizMag','VertWind','Unit','SoundSpeed','Temp','Date','Port'};

% MoTUS variable of interest (must be a subset of motus.header)
para.prepro.motus.varOfInterest = {'HorizDir','HorizMag','VertWind','Date'};

% MoTUS sample rate [Hz]
para.prepro.motus.sampleRate = 20;

% UNISAWS data header 
para.prepro.unisaws.header = {'Timestamp','RecordNbr','ID','AirTemp1','AirTemp2','AirTemp3','AirHumidity1','AirTemp4','AirHumidity2','AtmPressure','WindSpeed2m','WindDir2m','WindSpeed10m','WindDir10'};

% UNISAWS variable of interest (must be a subset of motus.header)
para.prepro.unisaws.varOfInterest = {'Timestamp','WindSpeed2m','WindDir2m','WindSpeed10m','WindDir10'};


    



writestruct(para, fullfile('.','para','default.xml'));




