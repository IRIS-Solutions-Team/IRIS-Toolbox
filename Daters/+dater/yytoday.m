function dateCode = yytoday( )
% numeric.yytoday  IRIS numeric date code for current year 
% 
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

[year, ~] = datevec(now( ));
dateCode = numeric.yy(year);

end%
