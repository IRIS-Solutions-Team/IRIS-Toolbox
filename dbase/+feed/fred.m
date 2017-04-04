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
% is an online database consisting of more than 385,000 economic data time
% series from 80 national, international, public, and private sources. 
% The `feed.fred( )` function provides access to those databases with IRIS.
%
% This function requires the Datafeed Toolbox.
%
%
% Example
% ========
%
% d = feed.fred('GDP','PCEC','FPI')
% 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

c = fred('https://research.stlouisfed.org/fred2/');
data = fetch(c,varargin);
close(c);
d = struct;
for i = 1:numel(data)
    [Y,M,D] = datevec(data(i).Data(:,1));
    % Note that Dates are start-of-period Dates in the FRED database
    switch regexp(data(i).Frequency,'\w+','match','once')
        case 'Daily'
            dates = data(i).Data(:,1);
        case 'Weekly'
            dates = ww(Y,M,D);
        case 'Monthly'
            dates = mm(Y,M);
        case 'Quarterly'
            dates = qq(Y,(M+2)/3);
        case 'Semiannual'
            dates = hh(Y,(M+2)/6);
        case 'Annual'
            dates = yy(Y);
        otherwise
            error('unknown freq: %s',data(i).Frequency)
    end
    meta = dbfun(@(x) strtrim(x),rmfield(data(i),'Data'));
    d.(meta.SeriesID) = userdata(tseries(dates,data(i).Data(:,2),meta.Title),meta);
end

end
