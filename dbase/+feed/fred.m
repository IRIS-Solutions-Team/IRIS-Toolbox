function outputData = fred(fredSeriesID, varargin)
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

outputData = struct( );
if isempty(fredSeriesID)
    return
end

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('feed/fred');
    INPUT_PARSER.addRequired('FredSeriesID', @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
    INPUT_PARSER.addParameter('URL', 'https://research.stlouisfed.org/fred2/', @(x) ischar(x) || isa(x, 'string'));
end

INPUT_PARSER.parse(fredSeriesID, varargin{:});
opt = INPUT_PARSER.Results;

%--------------------------------------------------------------------------

if ~iscell(fredSeriesID)
    fredSeriesID = cellstr(fredSeriesID);
end

c = fred(char(opt.URL));
dataStruct = fetch(c, fredSeriesID);
close(c);

numberOfSeries = numel(dataStruct);
unknownFrequencies = cell(1, 0);
for ithSeries = 1 : numberOfSeries
    freq = regexp(dataStruct(ithSeries).Frequency, '\w+', 'match', 'once');
    [year, month, day] = datevec(dataStruct(ithSeries).Data(:, 1));
    switch freq
        case 'Daily'
            dates = dataStruct(ithSeries).Data(:, 1);
        case 'Weekly'
            dates = ww(year, month, day);
        case 'Monthly'
            dates = mm(year, month);
        case 'Quarterly'
            dates = qq(year, month2per(month, 4));
        case 'Semiannual'
            dates = hh(year, month2per(month, 2));
        case 'Annual'
            dates = yy(year);
        otherwise
            unknownFrequencies{end+1} = fredSeriesID{ithSeries};
            continue
    end
    ithName = strtrim( dataStruct(ithSeries).SeriesID );
    ithData = dataStruct(ithSeries).Data(:, 2);
    ithComment = strtrim( dataStruct(ithSeries).Title );
    ithUserData = rmfield( dataStruct(ithSeries), 'Data' );
    outputData.(ithName) = Series(dates, ithData, ithComment, ithUserData);
end

if ~isempty(unknownFrequencies)
    throw( ...
        exception.Base('Dbase:FeedUnknownFrequency', 'warning'), ...
        unknownFrequencies ...
    );
end

end
