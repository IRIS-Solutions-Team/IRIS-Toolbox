function data = yearly(this, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('TimeSubscriptable.yearly');
    addRequired(pp, 'InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    addOptional(pp, 'YearlyDates', Inf, @hereValidateDates);
end
parse(pp, this, varargin{:});
range = pp.Results.YearlyDates;

%--------------------------------------------------------------------------

range = double(range);
if isequal(range, Inf)
    startYear = dater.convert(this.StartAsNumeric, Frequency.YEARLY);
    endYear = dater.convert(this.EndAsNumeric, Frequency.YEARLY);
    range = dater.colon(startYear, endYear);
end
range = reshape(range, [ ], 1);

freq = this.FrequencyAsNumeric;
func = @(year) dater.datecode(freq, year, 1:freq);
dates = arrayfun(func, dat2ypf(range), 'UniformOutput', false);
data = getData(this, [dates{:}]);
sizeData = size(data);
newSizeData = [freq, sizeData(1)/freq, sizeData(2:end)];
data = reshape(data, newSizeData);
data = permute(data, [2, 1, 3:ndims(data)]);

end

%
% Local Functions
%

function flag = hereValidateDates(input)
    input = double(input);
    if isequal(input, Inf)
        flag = true;
        return
    end
    if validate.properDate(input) ...
       && all(dater.getFrequency(input)==Frequency.YEARLY)
        flag = true;
        return
    end
    flag = false;
end%
