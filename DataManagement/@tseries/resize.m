function [this, newRange] = resize(this, range)
% resize  Clip tseries object to specified date range
%
% __Syntax__
%
%     X = resize(X, Range)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series whose date range will be clipped.
%
% * `Range` [ numeric ] - New date range to which the input tseries object
% will be resized; the range can be specified as a `[startDate, endDate]`
% vector where `-Inf` and `Inf` can be used for the dates.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Output tseries object with its date range clipped to
% `Range`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

if isempty(range) || isnan(this.Start)
    newRange = [ ];
    this = this.empty(this);
    return
elseif all(isinf(range)) || isequal(range, @all)
    newRange = this.Range;
    return
end

serialXStart = round(this.Start);
serialXEnd = serialXStart + size(this.Data, 1) - 1;
freq = getFrequency(this.Start);
rangeFirst = range(1);
rangeLast = range(end);

% Frequency of input tseries must be the same as frequency of new date
% range.
freqRangeFirst = DateWrapper.getFrequencyFromNumeric(rangeFirst);
freqRangeLast = DateWrapper.getFrequencyFromNumeric(rangeLast);
if ~freqcmp(freqRangeFirst, freq) || ~freqcmp(freqRangeLast, freq)
    utils.error('tseries:resize', ...
        ['Frequency of the tseries object and ', ...
        'the date frequency of the new range must be the same.']);
end

serialRangeFirst = round(rangeFirst);
serialRangeLast = round(rangeLast);

% Return immediately if start of new range is before start of input tseries
% and end of new range is after end of input tseries.
if serialRangeFirst<=serialXStart && serialRangeLast>=serialXEnd
    newRange = this.Range;
    return
end

if isinf(serialRangeFirst)
    serialStartDate = serialXStart;
else
    serialStartDate = serialRangeFirst;
end

if isinf(serialRangeLast)
    serialEndDate = serialXEnd;
else
    serialEndDate = serialRangeLast;
end

serialNewRange = serialStartDate : serialEndDate;
sizeData = size(this.Data);
numDates = sizeData(1);
pos = serialNewRange - serialXStart + 1;
indexDeleteRows = pos<1 | pos>numDates;
serialNewRange(indexDeleteRows) = [ ];
pos(indexDeleteRows) = [ ];

if ~isempty(pos)
    this.Data = this.Data(:, :);
    this.Data = this.Data(pos, :);
    this.Data = reshape(this.Data, [length(pos), sizeData(2:end)]);
    this.Start = DateWrapper.fromSerial(freq, serialNewRange(1));
else
    this = this.empty(this);
end

end
