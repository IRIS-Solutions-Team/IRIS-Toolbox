function this = removeWeekends(this)

persistent parser
if isempty(parser)
    parser = extend.InputParser('TimeSubscriptable/removeWeekends');
    addRequired(parser, 'InputSeries', @(x) isa(x, 'TimeSubscriptable') && x.Frequency==Frequency.DAILY);
end

%--------------------------------------------------------------------------

inxWeekends = DateWrapper.isWeekend(this.Range);
this.Data(inxWeekends, :) = this.MissingValue;

end%

