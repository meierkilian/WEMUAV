% This script generates a XML file containing all parameters needed for
% running all three main scripts. Storing parameters in an external XML
% file allows for modification of script parameters without any need to
% modify MATLAB scripts (useful in case of standalone compilation).

clear para

% week of GPS time [week nbr], if NaN then start is set at the first data point.
para.prepro.startTime.week = NaN; 

% time of week of GPS time [s], if NaN then start is set at the first data
% point.
para.prepro.startTime.tow = NaN;

% week of GPS time [week nbr], if NaN then end is set at the last data point.
para.prepro.endTime.week = NaN; 

% time of week of GPS time [s], if NaN then end is set at the last data
% point.
para.prepro.endTime.tow = NaN;

% time resolution at which the data is resampled, i.e. duration in [s]
% between two samples.
para.prepro.timeRes = 0.05; % 20 Hz

% path to reference data can be a vector of paths, must match size of
% flightInputpath
para.prepro.refInput.path = NaN;

% type of reference (describes the file formatting), available types are:
% {"default",...} TODO
para.prepro.refInput.type = 'default';

% path to flight data, can be a vector of paths, must match size of
% refInputpath
para.prepro.flightInput.path = fullfile('.','dev','rawData','FLY069_SHORT.csv');

% type of reference (describes the file formatting), available types are:
% {'default',...} TODO
para.prepro.flightInput.type = 'default';

% path to output folder
para.prepro.output.path = fullfile('.','dev','outData');

% type of output (describes the file formatting), available types are:
% {'default',...} TODO
para.prepro.output.type = 'default';


writestruct(para, fullfile('.','para','default.xml'));




