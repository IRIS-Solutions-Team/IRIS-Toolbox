function dateCode = xx(year, day)
% numeric.dd  Create date code for daily date
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin<2
    day = 1;
end

if numel(year)==1 && numel(day)>1
    year = repmat(year, size(day));
elseif numel(year)>1 && numel(day)==1
    day = repmat(day, size(year));
end

startYear = datenum(year, 1, 1);
dateCode = round(startYear + day - 1);

end%

