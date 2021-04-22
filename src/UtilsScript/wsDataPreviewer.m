%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WEATHER STATION DATA PREVIEWER
%
% DATE : 2021.04.21
%
% AUTHOR : Kilian Meier
%
% DESCRIPTION : The script shows the start and end GPS time of each weather
% station data present in the SD card. This is useful to rapidly find the
% data created during your last field trip. 
%
% HOW TO USE : modify the "weatherStationFolder" variable such that it
% corresponds to the mounting point of the weather station SD card. Modifiy
% "localTimeToUTC" such that it corresponds to the offset in hours between
% UTC and local time. Run the script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% PARAMETERS
weatherStationFolder = "F:"; % Mounting point of the SD card
localTimeToUTC = 2; % Hours of difference to UTC (i.e. summer in Switzerland is +2)

% CONSTANTS
dataFileFormatExtension = ".txt";
fileHeader = {'TOW','AirTemp1','AirHumidity','AtmPressure','WindSpeed','WindDir','GPSTime_Legacy','Lati','Long','Alti','GPSNbrSat','GPSLockFlag','TempCPU','TempSens','BattCharge','FanOn'};
textscanFormats = {'%f','%*f','%*f','%*f','%*f','%*s','%*f','%*f','%*f','%*f','%*f','%f','%*f','%*f','%*f','%*f'};

%-------------------------------------------------------------------------%
% Searching for data in SD card
D = dir(weatherStationFolder + "*" + dataFileFormatExtension);

% Variable size varible declaration
validNames = [""];
towStart = [];
towEnd = [];
idx = 1;

% Iterating over all data files found
for i = 1:length(D)
    % Creating a datastore for efficent access to data 
    ds = tabularTextDatastore(string(D(i).folder) + string(D(i).name), ...
        'NumHeaderLines', 0, ...
        'OutputType', 'table', ...
        'TextscanFormats', textscanFormats, ...
        'ReadVariableNames', false);
    ds.VariableNames = fileHeader;
    ds.SelectedVariableNames = {'TOW', 'GPSLockFlag'};
    
    % Loading the vriable of interst in memory
    data = readall(ds);
    gpsLockIdx = find(data.GPSLockFlag,1);
    
    % If GPS lock occured then the data is considered as valid and the
    % start and end time of week is stored
    if ~isempty(gpsLockIdx)
        validNames(idx) = string(D(i).name);
        towStart(idx) = data.TOW(gpsLockIdx);
        towEnd(idx) = data.TOW(end);
        idx = idx + 1;
    end
end

% Making column vectors
validNames = validNames';
towStart = towStart';
towEnd = towEnd';

% Using datetime structure to convert the tow seconds to day of week, hours
% minutes and duration. 2021-04-18 00:00:00 was arbitrarely chosen and
% could be any Sunday morning at 00:00:00 (start of GPS week)
dateStart = datetime(2021,04,18,0,0,0) + seconds(towStart) + hours(localTimeToUTC);
dateEnd = datetime(2021,04,18,0,0,0) + seconds(towEnd) + hours(localTimeToUTC);
duration = dateEnd-dateStart;

% Sorting data with respect to start time of the acquisition
results = table(validNames, dateStart, dateEnd, duration);
results = sortrows(results, 'dateStart');

% Displays the results. Keep in mind since the week nbr is not given it can
% be a given day in any week.
for i = 1:length(validNames)
    str = sprintf("%s  \tSTART : %s %02.0f:%02.0f\tEND %s %02.0f:%02.0f \t DURATION : %s", ...
        results.validNames(i), ...
        string(day(results.dateStart(i), 'shortname')),...
        hour(results.dateStart(i)), ...
        minute(results.dateStart(i)), ...
        string(day(results.dateEnd(i), 'shortname')),...
        hour(results.dateEnd(i)), ...
        minute(results.dateEnd(i)), ...
        string(results.duration(i)));
        
    disp(str)
end
