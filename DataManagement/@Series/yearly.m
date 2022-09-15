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
% __`~yearlyDates`__ [ Dater ] -
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
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, 'yearlyDates', Inf, @local_validateDates);
end
parse(ip, varargin{:});
range = ip.Results.yearlyDates;


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

end%


function flag = local_validateDates(input)
    %(
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
    %)
end%

