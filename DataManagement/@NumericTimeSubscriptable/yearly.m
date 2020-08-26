function data = yearly(this, varargin)
% yearly  Return array with time series data organized as one year per row
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     data = yearly(series, ~yearlyDates)
%
%
% ## Input Arguments ##
%
% __`series`__ [ Series ] -
% Input time series.
%
% __`~yearlyDates`__ [ DateWrapper ] -
% Years (dates of yearly frequency) for which the time series data will be
% returned; one year per row; if omitted, the data will be returned from
% the first year to the last year of the input `series`.
%
%
% ## Output Arguments ##
%
% __`data`__ [ numeric | logical ] -
% Array with the `series` data organized as one year per row; if the input
% `series` is a multivariate series, the 2nd and higher dimension will be
% shifted to 3rd and higher dimensions.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('NumericTimeSubscriptable.yearly');
    addRequired(pp, 'InputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addOptional(pp, 'YearlyDates', Inf, @hereValidateDates);
end
parse(pp, this, varargin{:});
range = pp.Results.YearlyDates;

%--------------------------------------------------------------------------

range = double(range);
if isequal(range, Inf)
    startYear = numeric.convert(this.StartAsNumeric, Frequency.YEARLY);
    endYear = numeric.convert(this.EndAsNumeric, Frequency.YEARLY);
    range = dater.colon(startYear, endYear);
end
range = reshape(range, [ ], 1);

freq = this.FrequencyAsNumeric;
func = @(year) numeric.datecode(freq, year, 1:freq);
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
    if DateWrapper.validateProperDateInput(input) ...
       && all(dater.getFrequency(input)==Frequency.YEARLY)
        flag = true;
        return
    end
    flag = false;
end%

