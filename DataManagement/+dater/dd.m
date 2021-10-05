% Type `web Dater/dd.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function dateCode = dd(year, month, day)

if nargin<2
    month = 1;
end

if nargin<3
    day = 1;
end

if validate.text(month)
    month = dater.monthFromString(month);
end

if any(month(:)<1 | month(:)>12)
    [year, month] = locallyFixMonths(year, month);
end

if isequal(day, "end")
    day = eomday(year, month);
end

if nargin<3
    day = 1;
elseif strcmpi(day, 'end')
    day = eomday(year, month);
end

dateCode = datenum(year, month, day);

end%

%
% Local Functions
%

function [year, month] = locallyFixMonths(year, month)
    %(
    if numel(year)==1 && numel(month)>1
        year = repmat(year, size(month));
    elseif numel(month)==1 && numel(year)>1
        month = repmat(month, size(year));
    end
    year = year + ceil(month/12) - 1;
    month = mod(month-1, 12) + 1;
    %)
end%

