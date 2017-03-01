function H = import_haver(hpath,varargin)
% import_haver  Import data from Haver Analytics databases
%
% Syntax
% =======
%
%      H = import_haver(hpath,dbfile1,series1,dbfile2,series2,...)
%
% Input arguments
% ================
%
% * `hpath` [ char ] - Directory where the Haver databases are stored
% (most likely a network location)
%
% * `dbfile1`,`dbfile1`,... [ char ] - Names of a Haver Analytics databases
% (without a suffix .dat)
%
% * `series1`,`series2`,... [ char | cellstr ] - Names of Haver Analytics series
% (not case sensitive)
%
% Description
% ============
%
% Haver Analytics (http://www.haver.com) provides more than 200 economic and
% financial databases in the form of .dat files to which you can purchase access.
% The import_haver function provides access to those databases with IRIS.
%
% Example
% ========
%
% H = import_haver('\\wahaverdb\DLX\DATA\','USECON','GDP')
% 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

d = {}; h = []; i=2; %#ok<*AGROW>
for dbfile = varargin(1:2:end)
    c = haver([hpath dbfile{1} '.dat']);
    d = [d fetch(c,varargin{i})];
    h = [h info(c,varargin{i})];
    close(c); i=i+2;
end

H=struct;
for j=1:size(d,2)
    switch h(j).Frequency
        case 'D'
            dates=d{j}(:,1);
        case 'FRI'
            dates=ww(year(d{j}(1)),month(d{j}(1)),day(d{j}(1)));
        case 'M'
            dates=mm(year(d{j}(1)),month(d{j}(1)));
        case 'Q'
            dates=qq(year(d{j}(1)),month(d{j}(1))/3);
        case 'Y'
            dates=yy(year(d{j}(1)));
        otherwise
            error('unknown freq: %s',h(j).Frequency)
    end
    H.(h(j).VarName)=userdata(tseries(dates,d{j}(:,2),h(j).Descriptor),h(j));
end
