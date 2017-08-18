function outputData = fred(varargin)
% feed.fred  Import data from FRED, Federal Reserve Bank of St. Louis database.
%
% Syntax
% =======
%
%      OutputDatabase = feed.fred(FredSeriesID, ...)
%
%
% Input arguments
% ================
%
% * `FredSeriesID` [ cellstr | string ] - FRED Series IDs for requested
% data (not case sensitive).
%
%
% Output arguments
% =================
%
% * `OutputDatabase` [ struct ] - Database containing imported FRED series.
%
%
% Options
% ========
%
% * `'URL='` [ *`'https://research.stlouisfed.org/fred2/'`* | char | string ] - URL for the database.
%
%
% Description
% ============
%
% Federal Reserve Economic Data, FRED (https://fred.stlouisfed.org/)
% is an online database consisting of more than 385, 000 economic data time
% series from 80 national, international, public, and private sources. 
% The `feed.fred( )` function provides access to those databases with IRIS.
%
% This function requires the Datafeed Toolbox.
%
%
% Example
% ========
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

%-----------------------------------------------------------

container = DatafeedContainer.fromFred(varargin{:});
outputData = export(container, @DateWrapper.fromSerial, @tseries);

end
