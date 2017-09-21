function outputDatabank = fred(varargin)
% feed.fred  Import data from FRED, Federal Reserve Bank of St. Louis databank.
%
% __Syntax__
%
%      OutputDatabank = feed.fred(FredSeriesID, ...)
%
%
% __Input Arguments__
%
% * `FredSeriesID` [ cellstr | string ] - FRED Series IDs for requested
% data (not case sensitive).
%
%
% __Output Arguments__
%
% * `OutputDatabank` [ struct ] - Databank containing imported FRED series.
%
%
% __Options__
%
% * `'URL='` [ *`'https://research.stlouisfed.org/fred2/'`* | char | string ] - URL for the databank.
%
%
% __Description__
%
% Federal Reserve Economic Data, FRED (https://fred.stlouisfed.org/)
% is an online databank consisting of more than 385, 000 economic data time
% series from 80 national, international, public, and private sources. 
% The `feed.fred( )` function provides access to those databanks with IRIS.
%
% This function requires the Datafeed Toolbox.
%
%
% __Example__
%
%     d = feed.fred({'GDP', 'PCEC', 'FPI'})
%  
%     d = 
%       struct with fields:
%     
%          GDP: [281x1 Series]
%         PCEC: [281x1 Series]
%          FPI: [281x1 Series]
% 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

timeSeriesConstructor = getappdata(0, 'IRIS_TimeSeriesConstructor');
dateFromSerial = getappdata(0, 'IRIS_DateFromSerial');

%--------------------------------------------------------------------------

container = DatafeedContainer.fromFred(varargin{:});
outputDatabank = export(container, dateFromSerial, timeSeriesConstructor);

end
