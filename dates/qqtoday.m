function outputDate = qqtoday( )
% qqtoday  IRIS date for current quarter
%
% __Syntax__
%
%     outputDate = qqtoday( )
%
%
% __Output arguments__
%
% * `outputDate` [ DateWrapper ]  - IRIS date (DateWrapper object) for the
% current quarter.
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

dateCode = numeric.qqtoday( );
outputDate = DateWrapper(dateCode);

end%
