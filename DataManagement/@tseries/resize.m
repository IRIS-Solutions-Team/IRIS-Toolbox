function [this, newRange] = resize(this, range)
% resize  Clip tseries object down to a specified date range.
%
% Syntax
% =======
%
%     X = resize(X, Range)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object whose date range will be clipped
% down.
%
% * `Range` [ numeric ] - New date range to which the input tseries object
% will be resized; the range can be specified as a `[startDate, endDate]`
% vector where `-Inf` and `Inf` can be used for the dates.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output tseries object with its date range clipped
% down to `Range`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries/resize');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addRequired('Range', @isnumeric);
end
INPUT_PARSER.parse(this, range);

%--------------------------------------------------------------------------

if isempty(range) || isnan(this.Start)
    newRange = [ ];
    this = empty(this);
    return
elseif all(isinf(range))
    newRange = this.Start + (0 : size(this.Data, 1)-1);
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
    newRange = this.Start + (0 : size(this.Data, 1)-1);
    return
end

if isinf(range(1))
    startDate = this.Start;
else
    startDate = range(1);
end

if isinf(range(end))
    endDate = this.Start + size(this.Data, 1) - 1;
else
    endDate = range(end);
end

newRange = startDate : endDate;
sizeOfData = size(this.Data);
numberOfDates = sizeOfData(1);
pos = round(newRange - this.Start + 1);
ixDeleteRows = pos<1 | pos>numberOfDates;
newRange(ixDeleteRows) = [ ];
pos(ixDeleteRows) = [ ];

if ~isempty(pos)
    this.Data = this.Data(:, :);
    this.Data = this.Data(pos, :);
    this.Data = reshape(this.Data, [length(pos), sizeOfData(2:end)]);
    this.Start = newRange(1);
else
    this.Data = zeros([0, sizeOfData(2:end)]);
    this.Start = NaN;
end

end
