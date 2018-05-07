function dat = ddtoday( )
% ddtoday  DateWrapper for today's daily date
%
% __Syntax__
%
%     dat = ddtoday( )
%
%
% __Output Arguments__
%
% * `dat` [ DateWrapper ]  - DateWrapper for today's daily date.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

dat = DateWrapper.fromSerial(Frequency.DAILY, floor(now( )));

end
