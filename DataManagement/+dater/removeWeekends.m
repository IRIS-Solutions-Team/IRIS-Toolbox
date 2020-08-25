function dates = removeWeekends(dates)

inxWeekend = dater.isWeekend(dates);
dates(inxWeekend) = [ ];

end%

