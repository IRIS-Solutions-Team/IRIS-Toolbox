function dateCode = hhtoday( )
% numeric.hhtoday  IRIS numeric date code for current half-year 
% 
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

[year, month] = datevec(now( ));
dateCode = hh(year, 1+floor((month-1)/6));

end%
