function dateCode = qqtoday( )
% numeric.qqtoday  IRIS numeric date code for current quarter
% 
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

[year, month] = datevec(now( ));
dateCode = qq(year, 1+floor((month-1)/3));

end%
