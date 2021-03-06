function para = ParaGen_PrePro()
% Generating parameters relevant for preprocessing

    %%%%%%%%%%%%%%%%% GENERAL PARAMETERS %%%%%%%%%%%%%%%%%
    
    % Path to Root of data folder
    para.datasetRoot = fullfile(".","sampleData");
    
    % Path to table containing the dataset overview, it is 
    % assumed that the table has at least the following columns :
    %  - DataStartTimeString : flight start time as a datetime string "dd-MMM-yyy hh:mm:ss"
    %  - DataEndTimeString : flight end time as a datetime string "dd-MMM-yyy hh:mm:ss"
    %  - ID : flight ID as an interger
    %  - FOLDER : path to flight folder which is expected to contain a "FLIGH\" and "WEATHER\" subfolder
    %  - FLIGHT : name of the flight CSV file as exported by DatCon
    %  - REF : path to the wind reference file, expected to be in "WEATHER\"
    %  - REFMETEO : path to the meteo reference file, expected to be in "WEATHER\
    %  - FlightType : string containing flight type
    para.datasetOverviewPath = fullfile(para.datasetRoot, "datasetOverview.xlsx");
    
    % Dataset overview table
    t = readtable(para.datasetOverviewPath);

    % ID of slected flight for preprocessing 
    para.selectedIdx = 1:3;
    
    if all(size(para.selectedIdx) == size(t.ID))
        disp("[ParaGen_Prepro] Selected ALL available files in dataset overview.")
    else
        disp("[ParaGen_Prepro] Selected idx : " + num2str(para.selectedIdx))
    end
    
    % Datetime of start time, if "" (empty string) then start is set at the first data point.
    para.startTime = string(t.DataStartTimeString(ismember(t.ID,para.selectedIdx)));

    % Datetime of end time, if "" (empty string) then end is set at the last data point.
    para.endTime = string(t.DataEndTimeString(ismember(t.ID,para.selectedIdx)));

    % Time resolution at which the data is resampled, i.e. duration in [s]
    % between two samples.
    para.timeRes = 0.1; % 10 Hz

    % Path to reference data, can be a vector of paths, must match size of flightInputpath
    % If the reference is of type "motus", then a folder is expected containing the different anemometer data.
    para.refInput.path = string(fullfile(para.datasetRoot, t.FOLDER(ismember(t.ID,para.selectedIdx)), "WEATHER", t.REF(ismember(t.ID,para.selectedIdx))));

    % Type of reference (describes the file formatting), available types are:
    % {'motus', 'unisaws', 'topoaws'}
    para.refInput.type = string(t.REFDATATYPE(ismember(t.ID,para.selectedIdx)));

    % Path to flight data, can be a vector of paths, must match size of refInputpath
    para.flightInput.path = string(fullfile(para.datasetRoot, t.FOLDER(ismember(t.ID,para.selectedIdx)), "FLIGHT", t.FLIGHT(ismember(t.ID,para.selectedIdx))));

    % Type of reference (describes the file formatting), available types are:
    % {'datconv3', 'datconv4'}
    para.flightInput.type = string(t.FLIGHTDATATYPE(ismember(t.ID,para.selectedIdx)));;

    % Path to meteo reference data (secondary reference), can be a vector of paths, must match size of flightInputpath
    para.refMeteoInput.path = string(fullfile(para.datasetRoot, t.FOLDER(ismember(t.ID,para.selectedIdx)), "WEATHER", t.REFMETEO(ismember(t.ID,para.selectedIdx))));

    % Type of reference (describes the file formatting), available types are:
    % {'motus', 'unisaws', 'topoaws'}
    para.refMeteoInput.type = string(t.REFMETEODATATYPE(ismember(t.ID,para.selectedIdx)));;

    % Path to output folder
    para.output.path = fullfile('.','outData','prepro');
    
    % field present in the output data (XYZ is the body fram and NED is considered as the local inertial frame)
    para.output.field = {...
        'lati', ... % [deg]
        'long', ... % [deg]
        'alti', ... % [m] above see level
        'vn', ... % [m/s]
        've', ... % [m/s]
        'vd', ... % [m/s]
        'ax', ... % [m/s^2]
        'ay', ... % [m/s^2]
        'az', ... % [m/s^2]
        'roll', ... % [rad]
        'pitch', ... % [rad]
        'yaw', ... % [rad]
        'q1', ... % []
        'q2', ... % []
        'q3', ... % []
        'q4', ... % []
        'gyroX', ... % [rad/s]
        'gyroY', ... % [rad/s]
        'gyroZ', ... % [rad/s]
        'motRpm_RF', ... % [rpm]
        'motRpm_LF', ... % [rpm]
        'motRpm_LB', ... % [rpm]
        'motRpm_RB', ... % [rpm]
        'windHDir_0150cm', ... % [deg]
        'windHMag_0150cm', ... % [m/s]
        'windVert_0150cm', ... % [m/s]
        'windHDir_1140cm', ... % [deg]
        'windHMag_1140cm', ... % [m/s]
        'windVert_1140cm', ... % [m/s]
        'windHDir_1470cm', ... % [deg]
        'windHMag_1470cm', ... % [m/s]
        'windVert_1470cm', ... % [m/s]
        'windHDir_1800cm', ... % [deg]
        'windHMag_1800cm', ... % [m/s]
        'windVert_1800cm', ... % [m/s]
        'windHDir_2130cm', ... % [deg]
        'windHMag_2130cm', ... % [m/s]
        'windVert_2130cm', ... % [m/s]
        'windHDir_other', ... % [deg]
        'windHMag_other', ... % [m/s]
        'windVert_other', ... % [m/s]
        'tempMotus', ... % [??C]
        'tempRef', ... % [??C]
        'pressAC', ... % [hPa]
        'pressRef', ... % [hPa]
        'humidAC', ... % [%]
        'humidRef' ... % [%]
        };


    %%%%%%%%%%%%%%%%% DATA SOURCE SPECIFIC PARAMETERS : DATCONV4 %%%%%%%%%%%%%%%%%
    % datconv4 date and time field name
    para.datconv4.UTCyear = 'gps_utc_data_gps_year_D';
    para.datconv4.UTCmonth = 'gps_utc_data_gps_month_D';
    para.datconv4.UTCday = 'gps_utc_data_gps_day_D';
    para.datconv4.UTChour = 'gps_utc_data_gps_hour_D';
    para.datconv4.UTCminute = 'gps_utc_data_gps_minute_D';
    para.datconv4.UTCsec = 'gps_utc_data_gps_sec_D'; % gps_utc_data_gps_sec_D is actually GPS time (with leapseconds) 
    para.datconv4.timeStamp = 'Clock_Tick_';

    % datconv4 drone internal clock frequency, used to compute adjusted time space
    para.datconv4.clkFreq = 4687453.40818485; % [Hz] (tick per seconds)

    % datcon4 nbr of leap seconds to UTC 
    para.datconv4.leapSec = 18;

    % datconv4 name of desired field, this is used to create a map from the
    % header of the file to the variable names as defined in
    % para.outout.field. Hence, this cell array must have the same size and
    % shape and must be ordered as in the para.output.field parameter. If a
    % field is not available an empty char array ('') should be used to
    % maintain size and order of the list.
    para.datconv4.varOfInterest = {...
        'IMU_ATTI_0__Latitude', ...
        'IMU_ATTI_0__Longitude', ...
        'IMU_ATTI_0__alti_D', ...
        'IMU_ATTI_0__velN', ...
        'IMU_ATTI_0__velE', ...
        'IMU_ATTI_0__velD', ...
        'IMU_ATTI_0__accelX', ...
        'IMU_ATTI_0__accelY', ...
        'IMU_ATTI_0__accelZ', ...
        '', ...
        '', ...
        '', ...
        'IMU_ATTI_0__quatW_D', ...
        'IMU_ATTI_0__quatX_D', ...
        'IMU_ATTI_0__quatY_D', ...
        'IMU_ATTI_0__quatZ_D', ...
        'IMU_ATTI_0__gyroX', ...
        'IMU_ATTI_0__gyroY', ...
        'IMU_ATTI_0__gyroZ', ...
        'Motor_Speed_RFront', ... % [rpm]
        'Motor_Speed_LFront', ... % [rpm]
        'Motor_Speed_LBack', ... % [rpm]
        'Motor_Speed_RBack', ... % [rpm]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        'AirSpeed_windFromDir', ... % [deg]
        'AirSpeed_windSpeed', ... % [m/s]
        'AirSpeed_comp_alti_D', ... % [m/s] 
        '', ... % [??C]
        '', ... % [??C]
        '', ... % [hPa]
        '', ... % [hPa]
        '', ... % [%]
        '' ... % [%]
        };

    % datconv4 unit conversion, list of factor to be applied to a given field 
    % to convert it to desired unit. This cell array must have the same size and
    % shape and must be ordered as in the para.output.field parameter.
    para.datconv4.unitConv = [ ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        9.81, ...
        9.81, ...
        9.81, ...
        pi/180, ...
        pi/180, ...
        pi/180, ...
        1, ...
        1, ...
        1, ...
        1, ...
        pi/180, ...
        pi/180, ...
        pi/180, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1 ...
        ];


    %%%%%%%%%%%%%%%%% DATA SOURCE SPECIFIC PARAMETERS : DATCONV3 %%%%%%%%%%%%%%%%%
    % datconv3 date and time field name
    para.datconv3.UTCdatetimeString = 'GPS_dateTimeStamp';
    para.datconv3.timeStamp = 'offsetTime';

    % datcon3 nbr of leap seconds to UTC 
    para.datconv3.leapSec = 0;

    % datconv3 name of desired field, this is used to create a map from the
    % header of the file to the variable names as defined in
    % para.outout.field. Hence, this cell array must have the same size and
    % shape and must be ordered as in the para.putout.field parameter. If a
    % field is not available an empty char array ('') should be used to
    % maintain size and order of the list.
    para.datconv3.varOfInterest = {...
        'IMU_ATTI_0__Latitude', ...
        'IMU_ATTI_0__Longitude', ...
        '', ...
        'IMU_ATTI_0__velN', ...
        'IMU_ATTI_0__velE', ...
        'IMU_ATTI_0__velD', ...
        'IMU_ATTI_0__accel_X', ...
        'IMU_ATTI_0__accel_Y', ...
        'IMU_ATTI_0__accel_Z', ...
        'IMU_ATTI_0__roll', ...
        'IMU_ATTI_0__pitch', ...
        'IMU_ATTI_0__yaw', ...
        '', ... % q1
        '', ... % q2
        '', ... % q3
        '', ... % q4
        'IMU_ATTI_0__gyro_X', ...
        'IMU_ATTI_0__gyro_Y', ...
        'IMU_ATTI_0__gyro_Z', ...
        'Motor_Speed_RFront', ...
        'Motor_Speed_LFront', ...
        'Motor_Speed_LBack', ...
        'Motor_Speed_RBack', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '', ...
        '' ...
        };

    % datconv3 unit conversion, list of factor to be applied to a given field 
    % to convert it to desired unit. This cell array must have the same size and
    % shape and must be ordered as in the para.output.field parameter.
    para.datconv3.unitConv = [ ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            9.81, ...
            9.81, ...
            9.81, ...
            0.0175, ...
            0.0175, ...
            0.0175, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1, ...
            1 ...
            ];        
    

    %%%%%%%%%%%%%%%%% DATA SOURCE SPECIFIC PARAMETERS : MOTUS %%%%%%%%%%%%%%%%%
    % MoTUS single sensor data header 
    para.motus.singleSensHeader = {'ID','windHDir','windHMag','windVert','unit','soundSpeed','temp','Date','port'};

    % MoTUS datetime column name
    para.motus.UTCdatetimeString = 'Date';

    % Port list
    para.motus.ports = {...
        'COM11', ...
        'COM14', ...
        'COM15', ...
        'COM16', ...
        'COM17', ...
    };

    % Anemometer altitude (must ordered as in para.motus.ports)
    para.motus.anemAlti = [...
        01.5, ...
        11.4, ...
        14.7, ...
        18.0, ...
        21.3
    ];

    % File extension of motus data
    para.motus.dataFileFormatExtension = ".txt";

    % MoTUS data is saved in local time, hence local2UTC in hours 
    % is added to the time vector to convert to UTC
    para.motus.local2UTC = -2;

    % MoTUS variable of interest 
    para.motus.varOfInterest = { ...
        '', ... % [deg]
        '', ... % [deg]
        '', ... % [m] above see level
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [m/s^2]
        '', ... % [m/s^2]
        '', ... % [m/s^2]
        '', ... % [rad]
        '', ... % [rad]
        '', ... % [rad]
        '', ... % []
        '', ... % []
        '', ... % []
        '', ... % []
        '', ... % [rad/s]
        '', ... % [rad/s]
        '', ... % [rad/s]
        '', ... % [rpm]
        '', ... % [rpm]
        '', ... % [rpm]
        '', ... % [rpm]
        'windHDir_0150cm', ... % [deg]
        'windHMag_0150cm', ... % [m/s]
        'windVert_0150cm', ... % [m/s]
        'windHDir_1140cm', ... % [deg]
        'windHMag_1140cm', ... % [m/s]
        'windVert_1140cm', ... % [m/s]
        'windHDir_1470cm', ... % [deg]
        'windHMag_1470cm', ... % [m/s]
        'windVert_1470cm', ... % [m/s]
        'windHDir_1800cm', ... % [deg]
        'windHMag_1800cm', ... % [m/s]
        'windVert_1800cm', ... % [m/s]
        'windHDir_2130cm', ... % [deg]
        'windHMag_2130cm', ... % [m/s]
        'windVert_2130cm', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [??C]
        'temp_2130cm', ... % [??C]
        '', ... % [hPa]
        '', ... % [hPa]
        '', ... % [%]
        '' ... % [%]
        };

    % motus unit conversion, list of factor to be applied to a given field 
    % to convert it to desired unit. This cell array must have the same size and
    % shape and must be ordered as in the para.output.field parameter.
    para.motus.unitConv = [ ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1 ...
        ];       


    %%%%%%%%%%%%%%%%% DATA SOURCE SPECIFIC PARAMETERS : UNISAWS %%%%%%%%%%%%%%%%%
    % UNISAWS data header 
    para.unisaws.header = {'Timestamp','RecordNbr','ID','AirTemp1','AirTemp2','AirTemp3','AirHumidity1','AirTemp4','AirHumidity2','AtmPressure','WindSpeed2m','WindDir2m','WindSpeed10m','WindDir10m'};

    % UNISAWS timestamp field name
    para.unisaws.timeStamp = 'Timestamp';

    % UNISAWS variable of interest (must be a subset of motus.header)
     % MoTUS variable of interest 
    para.unisaws.varOfInterest = { ...
        '', ... % [deg]
        '', ... % [deg]
        '', ... % [m] above see level
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [m/s^2]
        '', ... % [m/s^2]
        '', ... % [m/s^2]
        '', ... % [rad]
        '', ... % [rad]
        '', ... % [rad]
        '', ... % []
        '', ... % []
        '', ... % []
        '', ... % []
        '', ... % [rad/s]
        '', ... % [rad/s]
        '', ... % [rad/s]
        '', ... % [rpm]
        '', ... % [rpm]
        '', ... % [rpm]
        '', ... % [rpm]
        'WindDir2m', ... % [deg]
        'WindSpeed2m', ... % [m/s]
        '', ... % [m/s]
        'WindDir10m', ... % [deg]
        'WindSpeed10m', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [??C]
        'AirTemp1', ... % [??C]
        '', ... % [hPa]
        'AtmPressure' ... % [hPa]
        '', ... % [%]
        'AirHumidity1' % [%]
        };

    % unisaws unit conversion, list of factor to be applied to a given field 
    % to convert it to desired unit. This cell array must have the same size and
    % shape and must be ordered as in the para.output.field parameter.
    para.unisaws.unitConv = [ ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1 ...
        ];        


    %%%%%%%%%%%%%%%%% DATA SOURCE SPECIFIC PARAMETERS : TOPOAWS %%%%%%%%%%%%%%%%%
    % topoaws data header 
    para.topoaws.header = {'TOW','AirTemp1','AirHumidity','AtmPressure','WindSpeed','WindDir','GPSTime_Legacy','Lati','Long','Alti','GPSNbrSat','GPSLockFlag','TempCPU','TempSens','BattCharge','FanOn'};

    % topoaws gps time of week field name
    para.topoaws.tow = 'TOW';

    % topoaws gps lock flag field name 
    para.topoaws.gpsLock = 'GPSLockFlag';

    % topoaws datetime of the start of week of interest (replaces week nbr not present in topoaws data)
    % Carefull GPS week start on Sunday ! I.e. this datetime corresponds to moment where tow = 0
    % If it is set to "" then the file name is interpreted as a datetime string of the week start.
    para.topoaws.gpsWeekStart = "";

    % topoaws variable of interest (must be a subset of motus.header)
    para.topoaws.varOfInterest = { ...
        '', ... % [deg]
        '', ... % [deg]
        '', ... % [m] above see level
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [m/s^2]
        '', ... % [m/s^2]
        '', ... % [m/s^2]
        '', ... % [rad]
        '', ... % [rad]
        '', ... % [rad]
        '', ... % []
        '', ... % []
        '', ... % []
        '', ... % []
        '', ... % [rad/s]
        '', ... % [rad/s]
        '', ... % [rad/s]
        '', ... % [rpm]
        '', ... % [rpm]
        '', ... % [rpm]
        '', ... % [rpm]
        'WindDir', ... % [deg]
        'WindSpeed', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [deg]
        '', ... % [m/s]
        '', ... % [m/s]
        '', ... % [??C]
        '', ... % [??C]
        '', ... % [hPa]
        'AtmPressure' ... % [hPa]
        '', ... % [%]
        'AirHumidity' % [%]
        };

    % topoaws unit conversion, list of factor to be applied to a given field 
    % to convert it to desired unit. This cell array must have the same size and
    % shape and must be ordered as in the para.output.field parameter.
    para.topoaws.unitConv = [ ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1, ...
        1 ...
        ];        
    
end