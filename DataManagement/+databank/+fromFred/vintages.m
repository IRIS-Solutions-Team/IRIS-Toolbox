%{
% 
% # `databank.fromFred.vintage`
% 
% {== Download timestamps of available vintages for selected time series ==}
% 
% 
%}
% --8<--


function [outputDb, status, info] = vintages(seriesId, varargin)

[outputDb, status, info] = databank.fromFred.master("vintages", seriesId, varargin{:});

end%

