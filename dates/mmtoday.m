function outputDate = mmtoday( )
% mmtoday  IRIS date for current month
%
% __Syntax__
%
%     outputDate = mmtoday( )
%
%
% __Output arguments__
%
% * `outputDate` [ DateWrapper ]  - IRIS date (DateWrapper object) for the
% current month.
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

dateCode = numeric.mmtoday( );
outputDate = DateWrapper(dateCode);

end%
