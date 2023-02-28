% numeric.wwtoday  Iris numeric date code for current week
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function dateCode = wwtoday( )

    today = floor(now());
    dateCode = numeric.day2ww(today);

end%

