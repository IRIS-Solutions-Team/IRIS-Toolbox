function d = bloomberg(s,f,freq,fromdate,todate,varargin)
% feed.bloomberg  Import historical data from Bloomberg
%
% Syntax
% =======
%
% Input arguments marked with a `~` sign may be omitted.
%
%      d = feed.bloomberg(sec,fld,~freq,~fromdate,~todate,...)
%
% Input arguments
% ================
%
% * `sec` [ char | cellstr ] - Security list
% * `fld` [ char | cellstr ] - Bloomberg data fields
% * `~freq` [ char ] - Periodicity (see help blp/history)
% * `~fromdate` [ char | scalar ] - Beginning date
% * `~todate` [ char | scalar ] - End date
%
% Output arguments
% =================
%
% * `d` [ struct ] - Database containing imported Bloomberg series.
%
%
% Description
% ============
%
% Retrieve Bloomberg historical data for the security list SEC for the
% fields FLD using frequency FREQ for the dates FROMDATE to TODATE.
%
% This function requires the Datafeed Toolbox and Bloomberg Desktop API:
%
% javaaddpath c:\blp\DAPI\blpapi3.jar
%
%
% Example
% ========
%
% d = feed.bloomberg('USSOC Curncy','PX_LAST')
% d = feed.bloomberg('USSOC Curncy','PX_LAST','monthly')
% d = feed.bloomberg('SHOP US Equity','PX_LAST','daily','1/1/16','12/31/16')
% d = feed.bloomberg('SHOP CN Equity','PX_LAST','daily','1/1/16','12/31/16','USD')
% d = feed.bloomberg({'MSFT US Equity','IBM US Equity'},{'PX_OPEN','PX_LAST'},'monthly')
% 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Convert security list to cell array
if ischar(s)   
  s = cellstr(s);
end
% Convert field list to cell array
if ischar(f)   
  f = cellstr(f);
end
% Set daily frequency by default
if nargin<3
    freq = 'daily';
end
% Set maximum range by default
if nargin<4
    fromdate = datenum(1861,1,1);
    todate = datenum(9999,12,31);
end

c = blp;
[data,s] = history(c,s,f,fromdate,todate,freq,varargin);
desc = getdata(c,s,'NAME');
f = fieldinfo(c,f);
close(c);
% Convert data to cell array
if ~iscell(data)
  data = {data};
end
d = struct;
for i = 1:numel(data)
    if ~isnumeric(data{i}) || isempty(data{i})
        warning('%s is empty. %s',s{i},data{i});
        continue
    end
    [Y,M,D] = datevec(data{i}(:,1));
    switch freq
        case 'daily'
            dates = data{i}(:,1);
        case 'weekly'
            dates = ww(Y,M,D);
        case 'monthly'
            dates = mm(Y,M);
        case 'quarterly'
            dates = qq(Y,M/3);
        case 'semi_annually'
            dates = hh(Y,M/6);
        case 'yearly'
            dates = yy(Y);
        otherwise
            error('unknown freq: %s',freq)
    end
    ticker = regexp(s{i},'\w+','match','once');
    for j=1:size(f,1)
        tmp = Series(dates,data{i}(:,j+1),[desc.NAME{i} ', ' f{j,4}]);
        if size(f,1)>1
            d.(ticker).(f{j,3}) = tmp;
        else
            d.(ticker) = tmp;
        end
    end
end

end
