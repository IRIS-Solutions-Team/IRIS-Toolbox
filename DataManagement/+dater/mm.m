% numeric.mm  IRIS date code for monthly dates
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

function outputDate = mm(year, month)

if nargin<2
    month = 1;
end

if ischar(month) || isstring(month) || iscellstr(month)
    month = dater.monthFromString(month);
end

outputDate = numeric.datecode(12, year, month);

end%

