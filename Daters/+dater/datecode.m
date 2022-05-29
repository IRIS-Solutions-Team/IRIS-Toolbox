% dater.datecode  Create IrisT date code
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function dateCode = datecode(freq, varargin)

if nargin==1
    % No input arguments: current date
    dateCode = dater.today(freq);
    return
end

if nargin==2 && validate.text(varargin{1})
    % From ISO string: datecode("yyyy-mm-dd")
    dateCode = dater.fromIsoString(freq, string(varargin{1}));
    return
end

year = varargin{1};

if nargin>=3
    per = varargin{2};
else
    per = 1;
end

if nargin>=4
    day = varargin{3};
else
    day = 1;
end

freq = double(freq);
year = double(year);

% Determine the size of the resulting date array
temp = nan(size(freq)) + nan(size(year));
if isnumeric(per)
    temp = temp + nan(size(per));
end
if isnumeric(day)
    temp = temp + nan(size(day));
end

dateCode = nan(size(temp));

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

inxZero = freq==0;
inxDaily = freq==365;
inxWeekly = freq==52;
inxRegular = freq==1 | freq==2 | freq==4 | freq==6 | freq==12;

if any(~inxRegular & ~inxZero & ~inxDaily & ~inxWeekly)
    throw( exception.Base('Dates:UnrecognizedFrequency', 'error') );
end

if any(inxRegular)
    if (ischar(per) || isstring(per)) && isequal(string(per), "end")
        per = nan(size(freq));
        per(inxRegular) = freq(inxRegular);
    end
    serial = round(year(inxRegular)).*round(freq(inxRegular)) + round(per(inxRegular)) - 1;
    dateCode(inxRegular) = serial + round(freq(inxRegular))/100;
end

if any(inxZero)
    dateCode(inxZero) = round( per(inxZero) );
end

if any(inxDaily)
    dateCode(inxDaily) = dd(year, per, day);
end

if any(inxWeekly)
    if (ischar(per) || isstring(per)) && isequal(string(per), "end")
        per = nan(size(year));
        per(inxWeekly) = weeksinyear(year(inxWeekly));
    end
    day = fwymonday(year(inxWeekly)) + 7*(per(inxWeekly)-1);
    dateCode(inxWeekly) = numeric.day2ww(day);
end

end%

