% Type `web Dater/dd.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

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
% Patch Matlab bug when months are nonpositive
if any(month(:)<=0)
    [year, month] = locallyPatchNonpositiveMonths(year, month);
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

function [year, month] = locallyPatchNonpositiveMonths(year, month)
    %(
    inx = month<=0;
    if numel(year)==1 && numel(month)>1
        year = repmat(year, size(month));
    elseif numel(month)==1 && numel(year)>1
        month = repmat(month, size(year));
        inx = repmat(inx, size(year));
    end
    yearOffset = ceil(month(inx)/12) - 1;
    year(inx) = year(inx) + yearOffset;
    month(inx) = mod(month(inx)-1, 12) + 1;
    %)
end%

