function eom = dateom(dat)
% dateom  End of month for the specified daily date
%
% __Syntax__
%
%     eom = dateom(dat)
%
%
% __Input Arguments__
%
% * `dat` [ numeric ] - Daily serial date number.
%
%
% __Output Arguments__
%
% * `eom` [ numeric ] - Daily serial date number for the last day of the
% same month as `dat`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

[y, m] = datevec( double(dat) );
eom = datenum([y, m, eomday(y, m)]);

end%

