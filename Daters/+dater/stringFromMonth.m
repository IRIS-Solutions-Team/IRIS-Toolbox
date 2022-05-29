% dater.stringFromMonth.m  Convert textual monthNumeric to numeric monthNumeric

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function monthString = stringFromMonth(monthNumeric)


monthNames = [
    "January"
    "February"
    "March"
    "April"
    "May"
    "June"
    "July"
    "August"
    "September"
    "October"
    "November"
    "December" 
];

inx = monthNumeric<1 | monthNumeric>12;
if any(inx(:))
    monthNumeric(inx) = mod(monthNumeric(inx)-1, 12) + 1;
end
monthString = reshape(monthNames(monthNumeric), size(monthNumeric));

end%

