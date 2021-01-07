function [dates, inxWeekday] = removeWeekends(dates)

inxWeekend = dater.isWeekend(dates);
dates(inxWeekend) = [ ];

if nargout>=2 
    inxWeekday = ~inxWeekend;
end

end%

