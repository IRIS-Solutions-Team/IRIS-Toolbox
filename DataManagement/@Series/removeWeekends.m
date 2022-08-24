function this = removeWeekends(this)

inxWeekends = dater.isWeekend(this.RangeAsNumeric);
this.Data(inxWeekends, :) = this.MissingValue;
this = trim(this);

end%

