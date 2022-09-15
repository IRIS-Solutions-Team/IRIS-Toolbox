function dateCode = wwtoday( )
% numeric.wwtoday  IRIS numeric date code for current week
% 
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

today = floor(now( ));
dateCode = numeric.day2ww(today);

end%
