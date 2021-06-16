% TODO : update to handle know ws data...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WEATHER STATION DATA PREVIEWER
%
% DATE : 2021.06.12
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
weatherStationFolder = "C:\Users\Kilian\Documents\EPFL\PDM\SW\WSSensorCharacterisation\data\"; % Mounting point of the SD card
% weatherStationFolder = "F:"; % Mounting point of the SD card
localTimeToUTC = 2; % Hours of difference to UTC (i.e. summer in Switzerland is +2)

% CONSTANTS
dataFileFormatExtension = ".txt";
header = {'date','GPStime','temp','humidtiy','pression','windSpeed','windDir','lat','lng','alt','nbtSat','isValid','tCpu','tSens','battery','fan'};

%-------------------------------------------------------------------------%
% Searching for data in SD card
D = dir(weatherStationFolder + "*" + dataFileFormatExtension);
if isempty(D)
    disp("Empty folder")
    return
end

% Variable size varible declaration
validNames = [""];
towStart = [];
towEnd = [];
date = [];
idx = 1;

% Iterating over all data files found
for i = 1:length(D)
    % Creating a datastore for efficent access to data 
    ds = tabularTextDatastore(fullfile(D(i).folder, D(i).name), ...
        'NumHeaderLines', 1, ...
        'VariableNames',header ...
        );
    
    ds.SelectedVariableNames = {'date', 'GPStime', 'isValid'};
    
    % Loading the vriable of interst in memory
    data = readall(ds);
    gpsLockIdx = find(data.isValid,1);
    
    % If GPS lock occured then the data is considered as valid and the
    % start and end time of week is stored
    if ~isempty(gpsLockIdx)
        validNames(idx) = string(D(i).name);
        towStart(idx) = data.GPStime(gpsLockIdx);
        towEnd(idx) = data.GPStime(end);
        date(idx) = data.date(gpsLockIdx);
        idx = idx + 1;
    end
end

% Making column vectors
validNames = validNames';
towStart = towStart';
towEnd = towEnd';
date = date';

% Using datetime structure to convert the date and tow seconds to day of week, hours
% minutes and duration.
SEC_PER_DAY = seconds(days(1));
dateStart = datetime(string(date),'InputFormat','ddMMyy') + seconds(mod(towStart, SEC_PER_DAY)) + hours(localTimeToUTC);
dateEnd = datetime(string(date),'InputFormat','ddMMyy') + seconds(mod(towEnd, SEC_PER_DAY)) + hours(localTimeToUTC);
duration = dateEnd-dateStart;

% Sorting data with respect to start time of the acquisition
results = table(validNames, dateStart, dateEnd, duration);
results = sortrows(results, 'dateStart');

% Displays the results. Keep in mind since the week nbr is not given it can
% be a given day in any week.
for i = 1:length(validNames)
    str = sprintf("%s  \tSTART : %s\tEND %s\t DURATION : %s", ...
        results.validNames(i), ...
        datestr(results.dateStart(i)), ...
        datestr(results.dateEnd(i)), ...
        string(results.duration(i)) ...
    );
        
    disp(str)
end

reset(ds)
