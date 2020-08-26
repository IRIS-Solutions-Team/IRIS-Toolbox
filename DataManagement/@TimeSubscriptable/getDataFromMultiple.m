function [outputDates, varargout] = getDataFromMultiple(dates, varargin)

numSeries = numel(varargin);
varargout = cell(1, numSeries);

startDate = nan(1, numSeries);
endDate = nan(1, numSeries);
freq = nan(1, numSeries);
inxNaN = false(size(varargin));

if numSeries==0
    outputDates = DateWrapper.empty(1, 0);
    return
end

for i = 1 : numSeries
    startDate(i) = double(varargin{i}.Start);
    endDate(i) = double(varargin{i}.End);
    freq(i) = dater.getFrequency(startDate(i));
    inxNaN(i) = isnan(startDate(i));
end

if all(inxNaN)
    outputDates = DateWrapper.empty(1, 0);
    for i = 1 : numSeries
        varargout{i} = varargin{i}.Data;
    end
    return
end

if isnumeric(dates)
    outputDates = double(dates);
    for i = 1 : numSeries
        varargout{i} = getDataNoFrills(varargin{i}, dates);
    end
    return
end

if ~all(freq==freq(1))
    throw(exception.Base([
        "Series:NonhomogeneousFrequency"
        "All the time series that are being combined must be "
        "of the same date frequency when long range or short range is requested. "
    ], 'error'));
end

if matches(dates, "longRange", "ignoreCase", true)
    from = min(startDate); 
    to = max(endDate); 
elseif matches(dates, "shortRange", "ignoreCase", true)
    from = max(startDate); 
    to = min(endDate); 
else
    throw(exception.Base([
        "Series:NonhomogeneousFrequency"
        "Invalid date range specification; it needs to be "
        "one of { DateWrapper, ""longRange"", ""shortRange"" }. "
    ], 'error'));
end

for i = 1 : numSeries
    varargout{i} = getDataFromTo(varargin{i}, from, to);
end
outputDates = dater.colon(from, to);

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
    assertEqual(testCase, dates, qq(2020,1):qq(2020,42), "absTol", 1e-12);


%% Test Short Range
    [dates, x, y, z] = getDataFromMultiple("shortRange", d.x, d.y, d.z);
    assertEqual(testCase, dates, qq(2020,3):qq(2020,38), "absTol", 1e-12);


##### SOURCE END #####
%}


