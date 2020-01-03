function outputSerial = dd(year, month, day)
% numeric.dd  Create serial date number for daily dates
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin<2
    month = 1;
end

if ischar(month)
    month = cellstr(month);
end

if iscellstr(month)
    monthList = { 'jan', 'feb', 'mar', 'apr', 'may', 'jun', ...
                  'jul', 'aug', 'sep', 'oct', 'nov', 'dec'  };
    temp = month;
    month = nan(size(temp));
    for i = 1 : numel(month)
        month(i) = find(strncmpi(temp{i}, monthList, 3));
    end
end

% Patch Matlab bug when months are nonpositive
index = month<=0;
if any(index)
    if numel(year)==1 && numel(month)>1
        year = repmat(year, size(month));
    elseif numel(month)==1 && numel(year)>1
        month = repmat(month, size(year));
        index = repmat(index, size(year));
    end
    yearOffset = ceil(month(index)/12) - 1;
    year(index) = year(index) + yearOffset;
    month(index) = mod(month(index)-1, 12) + 1;
end

if nargin<3
    day = 1;
elseif strcmpi(day, 'end')
    day = eomday(year, month);
end

outputSerial = datenum(year, month, day);

end%

