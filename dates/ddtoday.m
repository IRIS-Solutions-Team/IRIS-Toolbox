function outputDate = ddtoday( )
% ddtoday  IRIS date for current day
%
% __Syntax__
%
%     outputDate = ddtoday( )
%
%
% __Output Arguments__
%
% * `outputDate` [ DateWrapper ] - IRIS date (DateWrapper object) for the
% current day.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.ddtoday( );
outputDate = DateWrapper(dateCode);

end%
