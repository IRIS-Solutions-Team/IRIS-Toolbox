% datxom  Beginning or end of month for the specified daily or monthly date
%{
% ## Syntax_##
%
%     xom = datxom(dateCode, 'Start')
%     xom = datxom(dateCode, 'End')
%
%
% ## Input Arguments ##
%
% * `dat` [ DateWrapper | numeric ] - Daily or monthly date.
%
%
% ## Output Arguments ##
%
% * `xom` [ DateWrapper | numeric ] - Daily date for the first or last day of the
% same month as `dateCode`, depending on the second input argument.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function xomDateCode = datxom(dateCode, x)

isDater = isa(dateCode, 'DateWrapper');

dateCode = double(dateCode);
sizeDateCode = size(dateCode);
dateCode = dateCode(:);

freq = dater.getFrequency(dateCode);
inxDaily = freq==frequency.DAILY;
inxMonthly = freq==frequency.MONTHLY;

xomDateCode = nan(size(dateCode));
year = nan(size(dateCode));
month = nan(size(dateCode));

if any(inxDaily)
    [year(inxDaily), month(inxDaily)] = datevec(dateCode(inxDaily));
end

if any(inxMonthly)
    [year(inxMonthly), month(inxMonthly)] = dat2ypf(dateCode(inxMonthly));
end

day = nan(size(year));
inx = inxDaily | inxMonthly;
if strncmpi(x, 's', 1) || strncmpi(x, 'b', 1)
    day(inx) = 1;
elseif strncmpi(x, 'e', 1)
    day(inx) = eomday(year(inx), month(inx));
end
xomDateCode(inx) = datenum([year(inx), month(inx), day(inx)]);
xomDateCode = reshape(xomDateCode, sizeDateCode);

if isDater
    xomDateCode = Dater(xomDateCode);
end

end%

