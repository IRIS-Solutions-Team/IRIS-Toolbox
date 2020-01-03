function outputDate = wwtoday( )
% wwtoday  IRIS date for current week
%
% __Syntax__
%
%     outputDate = wwtoday( )
%
%
% __Output arguments__
%
% * `outputDate` [ DateWrapper ]  - IRIS date (DateWrapper object) for the
% current week.
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

dateCode = numeric.wwtoday( );
outputDate = DateWrapper(dateCode);

end%
