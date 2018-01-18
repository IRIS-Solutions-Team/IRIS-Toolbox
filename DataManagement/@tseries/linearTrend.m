function this = linearTrend(range, step, varargin)
% linearTrend  Create time series with linear trend
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = tseries.linearTrend(Range, Step, ~Start)
%
%
% __Input Arguments__
%
% * `Range` [ DateWrapper ] - Date range on which the trend time series
% will be created.
%
% * `Step` [ numeric ] - Difference between two consecutive dates in the
% trend.
%
% * `~Start` [ numeric ] - Starting value for the trend; if omitted, the
% trend will start at zero.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Time series with a linear trend.
%
%
% __Description__
%
%
% __Example__
%

% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries/linearTrend');
    inputParser.addRequired('Range', @DateWrapper.validateProperRangeInput);
    inputParser.addRequired('Step', @(x) isnumeric(x) && size(x, 1)==1);
    inputParser.addOptional('Start', 0, @(x) isnumeric(x) && size(x, 1)==1);
end
inputParser.parse(range, step, varargin{:});
start = inputParser.Results.Start;
if ~isa(range, 'DateWrapper')
    range = DateWrapper(range);
end

%--------------------------------------------------------------------------

numOfPeriods =  rnglen(range);
zeroStart = zeros(size(step));
step = repmat(step, numOfPeriods-1, 1);
data = cumsum([zeroStart; step], 1);
if any(start(:))~=0
    start = repmat(start, numOfPeriods, 1);
    data = data + start;
end
this = tseries(range(1), data);

end

