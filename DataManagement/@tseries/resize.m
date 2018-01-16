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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries/resize');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addRequired('Range', @DateWrapper.validateRangeInput);
end
INPUT_PARSER.parse(this, range);

%--------------------------------------------------------------------------

if isempty(range) || isnan(this.Start)
    newRange = [ ];
    this = this.empty(this);
    return
elseif all(isinf(range)) || isequal(range, @all)
    newRange = this.Range;
    return
end

% Frequency of input tseries must be the same as frequency of new date
% range.
if ~all(freqcmp(range([1, end]), this.Start))
    utils.error('tseries:resize', ...
        ['Frequency of the tseries object and ', ...
        'the date frequency of the new range must be the same.']);
end

% Return immediately if start of new range is before start of input tseries
% and end of new range is after end of input tseries.
if round(range(1))<=round(this.Start) ...
        && round(range(end))>=round(this.Start + size(this.Data, 1) - 1)
    newRange = this.Range;
    return
end

if isinf(range(1))
    startDate = this.Start;
else
    startDate = range(1);
end

if isinf(range(end))
    endDate = this.End;
else
    endDate = range(end);
end

newRange = startDate : endDate;
sizeData = size(this.Data);
numDates = sizeData(1);
pos = round(newRange - this.Start + 1);
indexDeleteRows = pos<1 | pos>numDates;
newRange(indexDeleteRows) = [ ];
pos(indexDeleteRows) = [ ];

if ~isempty(pos)
    this.Data = this.Data(:, :);
    this.Data = this.Data(pos, :);
    this.Data = reshape(this.Data, [length(pos), sizeData(2:end)]);
    this.Start = newRange(1);
else
    this = this.empty(this);
end

end
