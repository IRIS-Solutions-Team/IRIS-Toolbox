function [dates, inxWeekday] = removeWeekends(dates)

freq = dater.getFrequency(dates);
if any(freq~=Frequency.DAILY)
    exception.error([
        "Dater:RemoveWeekendsNonDaily"
        "The function dater.removeWeekends() can be applied to daily frequency dates only."
    ]);
end

inxWeekend = dater.isWeekend(dates);
dates(inxWeekend) = [ ];

if nargout>=2 
    inxWeekday = ~inxWeekend;
end

end%

