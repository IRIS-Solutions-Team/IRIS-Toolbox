function outputDate = hhtoday( )
% hhtoday  IRIS date for current half-year
%
% __Syntax__
%
%     outputDate = hhtoday( )
%
%
% __Output arguments__
%
% * `outputDate` [ DateWrapper ]  - IRIS date (DateWrapper object) for the
% current half-year.
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

dateCode = numeric.hhtoday( );
outputDate = DateWrapper(dateCode);

end%
