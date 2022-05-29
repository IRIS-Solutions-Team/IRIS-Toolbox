function eomDateCode = dateom(dateCode)
% dateom  End of month for the specified daily or monthly date
%
% __Syntax__
%
%     eom = dateom(dat)
%
%
% __Input Arguments__
%
% * `dat` [ DateWrapper | numeric ] - Daily or monthly date.
%
%
% __Output Arguments__
%
% * `eom` [ DateWrapper | numeric ] - Daily date for the last day of the
% same month as `dat`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

eomDateCode = datxom(dateCode, 'end');

end%

