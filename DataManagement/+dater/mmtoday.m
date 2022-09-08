function dateCode = mmtoday( )
% numeric.mmtoday  IRIS numeric date code for current month
% 
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

[year, month] = datevec(now( ));
dateCode = mm(year, month);

end%
