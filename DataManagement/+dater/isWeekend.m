function inxWeekend = isWeekend(dates)

weekday = weekdayiso(double(dates));
inxWeekend = weekday==6 | weekday==7;

end%

