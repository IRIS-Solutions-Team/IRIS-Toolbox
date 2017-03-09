function d = import(varargin)
% import  Import data from FRED, Federal Reserve Bank of St. Louis
%
% Syntax
% =======
%
%      d = fred.import(series1, series2, ...)
%
%
% Input arguments
% ================
%
% * `series1`, `series2`, ... [ char ] - Names of FRED series
% (not case sensitive)
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
% The `fred.import( )` function provides access to those databases with IRIS.
%
%
% Example
% ========
%
% d = fred.import('GDP','PCEC','FPI')
% 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

c = fred('https://research.stlouisfed.org/fred2/');
data = fetch(c,varargin);
close(c)
d = struct;
for i = 1:numel(data)
    % Note that Dates are start-of-period Dates in the FRED database
    switch regexp(data(i).Frequency,'\w+','match','once')
        case 'Daily'
            dates = data(i).Data(:,1);
        case 'Weekly'
            dates = ww(year(data(i).Data(1)),month(data(i).Data(1)),day(data(i).Data(1)));
        case 'Monthly'
            dates = mm(year(data(i).Data(1)),month(data(i).Data(1)));
        case 'Quarterly'
            dates = qq(year(data(i).Data(1)),(month(data(i).Data(1))+2)/3);
        case 'Semiannual'
            dates = hh(year(data(i).Data(1)),(month(data(i).Data(1))+2)/6);
        case 'Annual'
            dates = yy(year(data(i).Data(1)));
        otherwise
            error('unknown freq: %s',data(i).Frequency)
    end
    d.(strtrim(data(i).SeriesID)) = userdata( ...
        tseries(dates,data(i).Data(:,2),strtrim(data(i).Title)), ...
        rmfield(data(i),'Data') );
end

end
