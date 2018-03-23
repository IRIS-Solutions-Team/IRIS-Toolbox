function this = linearTrend(range, step, varargin)
% linearTrend  Create time series with linear trend.
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%   X = Series.linearTrend(Range, Step, ~Start)
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
% `X` [ Series ] - Time series with a linear trend.
%
%
% __Description__
%
%
% __Example__
%

% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('Series.linearTrend');
    INPUT_PARSER.addRequired('Range', @DateWrapper.validateProperRangeInput);
    INPUT_PARSER.addRequired('Step', @(x) isnumeric(x) && size(x, 1)==1);
    INPUT_PARSER.addOptional('Start', 0, @(x) isnumeric(x) && size(x, 1)==1);
end
INPUT_PARSER.parse(range, step, varargin{:});
start = INPUT_PARSER.Results.Start;
if ~isa(range, 'DateWrapper')
    range = DateWrapper(range);
end

%--------------------------------------------------------------------------

numPeriods =  rnglen(range);
zeroStart = zeros(size(step));
step = repmat(step, numPeriods-1, 1);
data = cumsum([zeroStart; step], 1);
if any(start(:))~=0
    start = repmat(start, numPeriods, 1);
    data = data + start;
end
this = Series(range(1), data);

end

