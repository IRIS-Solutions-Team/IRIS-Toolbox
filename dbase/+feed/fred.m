function d = fred(varargin)
% feed.fred  Import data from FRED, Federal Reserve Bank of St. Louis.
%
% Syntax
% =======
%
%      d = feed.fred(series1, series2, ...)
%
%
% Input arguments
% ================
%
% * `series1`, `series2`, ... [ char ] - Names of FRED series
% (not case sensitive).
%
%
% Output arguments
% =================
%
% * `d` [ struct ] - Database containing imported FRED series.
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
% d = feed.fred('GDP', 'PCEC', 'FPI')
% 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

c = fred('https://research.stlouisfed.org/fred2/');
data = fetch(c, varargin);
close(c);

d = struct( );
nData = numel(data);
lsUnknownFreq = cell(1, 0);
for i = 1 : nData
    freq = regexp(data(i).Frequency, '\w+', 'match', 'once');
    v = datevec(data(i).Data(:, 1));
    switch freq
        case 'Daily'
            dates = data(i).Data(:, 1);
        case 'Weekly'
            dates = ww(v(:, 1), v(:, 2), v(:, 3));
        case 'Monthly'
            dates = mm(v(:, 1), v(:, 2));
        case 'Quarterly'
            dates = qq(v(:, 1), month2per(v(:, 2), 4));
        case 'Semiannual'
            dates = hh(v(:, 1), month2per(v(:, 2), 2));
        case 'Annual'
            dates = yy(v(:, 1));
        otherwise
            lsUnknownFreq{end+1} = varargin{i};
            continue
    end
    name = strtrim(data(i).SeriesID);
    comment = strtrim(data(i).Title);
    userData = rmfield(data(i), 'Data');
    d.(name) = Series(dates, data(i).Data(:, 2), comment, userData);
end

if ~isempty(lsUnknownFreq)
    throw( ...
        exception.Base('Dbase:FeedUnknownFrequency', 'warning'), ...
        lsUnknownFreq ...
        );
end

end
