function dat = datecode(freq, year, per, varargin)
% numeric.datcode  Create IRIS date code
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if nargin<3
    per = 1;
end

if ~isempty(varargin)
    day = varargin{1};
    varargin(1) = [ ];
else
    day = 1;
end

%--------------------------------------------------------------------------

year = round(year);

% Determine the size of the resulting date array
temp = nan(size(freq)) + nan(size(year));
if isnumeric(per)
    temp = temp + nan(size(per));
end
if isnumeric(day)
    temp = temp + nan(size(day));
end

dat = nan(size(temp));

if numel(freq)==1
    freq = repmat(freq, size(temp));
end

if numel(year)==1
    year = repmat(year, size(temp));
end

if numel(per)==1
    per = repmat(per, size(temp));
end

if numel(day)==1
    day = repmat(day, size(temp));
end

inxOfZero    = freq==0;
inxOfDaily   = freq==365;
inxOfWeekly  = freq==52;
inxOfRegular = freq==1 | freq==2 | freq==4 | freq==6 | freq==12;

if any(~inxOfRegular & ~inxOfZero & ~inxOfDaily & ~inxOfWeekly)
    throw( exception.Base('Dates:UnrecognizedFrequency', 'error') );
end

if any(inxOfRegular)
    if isequal(per, 'end')
        per = nan(size(freq));
        per(inxOfRegular) = freq(inxOfRegular);
    end
    serial = round(year(inxOfRegular)).*round(freq(inxOfRegular)) + round(per(inxOfRegular)) - 1;
    dat(inxOfRegular) = serial + round(freq(inxOfRegular))/100;
end

if any(inxOfZero)
    dat(inxOfZero) = round( per(inxOfZero) );
end

if any(inxOfDaily)
    dat(inxOfDaily) = dd(year, per, day);
end

if any(inxOfWeekly)
    if isequal(per, 'end')
        per = nan(size(year));
        per(inxOfWeekly) = weeksinyear(year(inxOfWeekly));
    end
    day = fwymonday(year(inxOfWeekly)) + 7*(per(inxOfWeekly)-1);
    dat(inxOfWeekly) = numeric.day2ww(day);
end

end%

