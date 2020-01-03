function outputDate = yytoday( )
% yytoday  IRIS date for current year
%
% __Syntax__
%
%     outputDate = yytoday( )
%
%
% __Output arguments__
%
% * `outputDate` [ DateWrapper ]  - IRIS date (DateWrapper object) for the
% current year.
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

dateCode = numeric.yytoday( );
outputDate = DateWrapper(dateCode);

end%
