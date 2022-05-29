% dater.monthFromString  Convert textual monthNumeric to numeric monthNumeric

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function monthNumeric = monthFromString(monthString)

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
lowerMonthNames = lower(extractBefore(monthNames, 4));
monthString = string(monthString);
lowerMonthString = extractBefore(lower(monthString), 4);
monthNumeric = nan(size(monthString));
invalid = string.empty(1, 0);
for i = 1 : numel(monthString)
    if lowerMonthString(i)=="end"
        monthNumeric(i) = 12;
        continue
    end
    inx = lowerMonthString(i)==lowerMonthNames;
    if any(inx)
        monthNumeric(i) = find(inx);
        continue
    end
    invalid(end+1) = monthString(i);
end
if ~isempty(invalid)
    exception.error([
        "Dater:InvalidMonthString"
        "This is not a valid month string: %s"
    ], unique(invalid));
end

end%

