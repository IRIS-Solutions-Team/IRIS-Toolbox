function [outputDates, varargout] = getDataFromMultiple(dates, context, varargin)

% >=R2019b
%{
arguments
    dates
    context (1, 1) string
end

arguments (Repeating)
    varargin
end
%}
% >=R2019b

inputSeries = varargin;


if isequal(dates, @all) || isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
    dates = "unbalanced";
end

if ~isstring(dates)
    dates = double(dates);
end

numSeries = numel(inputSeries);
varargout = cell(1, numSeries);

startDate = nan(1, numSeries);
endDate = nan(1, numSeries);
freq = nan(1, numSeries);
inxNaN = false(size(inputSeries));

if numSeries==0
    outputDates = double.empty(1, 0);
    return
end

for i = 1 : numSeries
    startDate(i) = double(inputSeries{i}.Start);
    endDate(i) = inputSeries{i}.EndAsNumeric;
    freq(i) = dater.getFrequency(startDate(i));
    inxNaN(i) = isnan(startDate(i));
end

if all(inxNaN)
    outputDates = double.empty(1, 0);
    for i = 1 : numSeries
        varargout{i} = inputSeries{i}.Data;
    end
    return
end

if isnumeric(dates)
    locallyCheckFrequencyWhenProperDates(dates, freq, context);
    outputDates = double(dates);
    for i = 1 : numSeries
        varargout{i} = getDataNoFrills(inputSeries{i}, dates);
    end
    return
end

locallyCheckFrequencyWhenImproperDates(freq, context);

if startsWith(dates, ["unbalanced", "longRange"], "ignoreCase", true)
    from = min(startDate); 
    to = max(endDate); 
elseif startsWith(dates, ["balanced", "shortRange"], "ignoreCase", true)
    from = max(startDate); 
    to = min(endDate); 
else
    exception.error([
        "Series"
        "Invalid date range specification; it needs to be "
        "one of { dater, ""longRange"", ""shortRange"" }. "
    ]);
end

for i = 1 : numSeries
    varargout{i} = getDataFromTo(inputSeries{i}, from, to);
end
outputDates = dater.colon(from, to);

end%

%
% Localy Functions
%

function locallyCheckFrequencyWhenProperDates(dates, freqSeries, context)
    %(
    freqSeries = double(freqSeries);
    freqSeries(isnan(freqSeries)) = [];
    if isempty(freqSeries)
        return
    end
    if isempty(dates)
        locallyCheckFrequencyWhenImproperDates(freqSeries, context);
        return
    end
    freqDates = dater.getFrequency(dates(1));
    if all(freqSeries==freqDates)
        return
    end
    exception.error([
        "Series:FrequencyMismatch"
        "Date frequency of some time series is incosistent with the dates requested."
    ]);
    %)
end%


function locallyCheckFrequencyWhenImproperDates(freq, context)
    %(
    freq0 = freq;
    freq(isnan(freq)) = [];
    if isempty(freq) || all(freq==freq(1))
        return
    end
    freq0 = unique(string(Frequency(freq0)));
    exception.error([
        "Series:FrequencyMismatch"
        "Date frequency mismatch in input time series: %s(%s)"
    ], context, join(freq0, ", "));
    %)
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/getDAtaFromMultiple.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


%% Test Plain Dates
    d = struct( );
    d.x = Series(qq(2020,1:40), @rand);
    d.y = Series(qq(2020,2:38), @rand);
    d.z = Series(qq(2020,3:42), @rand);
    %
    range = qq(2020,1) : qq(2020,42);
    [dates, f.x, f.y, f.z] = getDataFromMultiple(range, d.x, d.y, d.z);
    for n = ["x", "y", "z"]
        assertEqual(testCase, d.(n)(range), f.(n));
    end


% Test Long Range
    [dates, x, y, z] = getDataFromMultiple("longRange", d.x, d.y, d.z);
    assertEqual(testCase, dates, dater.colon(dater.qq(2020,1), dater.qq(2020,42)), "absTol", 1e-12);


%% Test Short Range
    [dates, x, y, z] = getDataFromMultiple("shortRange", d.x, d.y, d.z);
    assertEqual(testCase, dates, dater.colon(dater.qq(2020,3), dater.qq(2020,38)), "absTol", 1e-12);


##### SOURCE END #####
%}

