function d = import(hpath, varargin)
% import  Import data from Haver Analytics databases
%
% Syntax
% =======
%
%      d = haver.import(hpath, dbfile1, series1, dbfile2, series2, ...)
%
%
% Input arguments
% ================
%
% * `hpath` [ char ] - Directory where the Haver databases are stored
% (most likely a network location)
%
% * `dbfile1`, `dbfile1`, ... [ char ] - Names of a Haver Analytics databases
% (without a suffix .dat)
%
% * `series1`, `series2`, ... [ char | cellstr ] - Names of Haver Analytics series
% (not case sensitive)
%
%
% Output arguments
% =================
%
% * `d` [ struct ] - Database containing imported Haver series.
%
%
% Description
% ============
%
% Haver Analytics (http://www.haver.com) provides more than 200 economic and
% financial databases in the form of .dat files to which you can purchase access.
% The `haver.import( )` function provides access to those databases with IRIS.
%
%
% Example
% ========
%
% d = haver.import('\\wahaverdb\DLX\DATA\', 'USECON', 'GDP')
% 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

data = {}; meta = []; i=2; %#ok<*AGROW>
for dbfile = varargin(1:2:end)
    h = haver([hpath dbfile{1} '.dat']);
    data = [data fetch(h,varargin{i})];
    meta = [meta info(h,varargin{i})];
    close(h); i=i+2;
end

d = struct;
for i=1:size(data,2)
    switch meta(i).Frequency
        case 'D'
            dates=data{i}(:,1);
        case 'FRI'
            dates=ww(year(data{i}(1)),month(data{i}(1)),day(data{i}(1)));
        case 'M'
            dates=mm(year(data{i}(1)),month(data{i}(1)));
        case 'Q'
            dates=qq(year(data{i}(1)),month(data{i}(1))/3);
        case 'Y'
            dates=yy(year(data{i}(1)));
        otherwise
            error('unknown freq: %s',meta(i).Frequency)
    end
    d.(meta(i).VarName)=userdata(tseries(dates,data{i}(:,2),meta(i).Descriptor),meta(i));
end

end
