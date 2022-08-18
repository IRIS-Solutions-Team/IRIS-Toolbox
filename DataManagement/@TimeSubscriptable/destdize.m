function this = destdize(this, meanX, stdX)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('TimeSubscriptable.destdize');
    inputParser.addRequired('inputSeries', @(x) isa(x, 'TimeSubscriptable'));
    inputParser.addRequired('meanX', @isnumeric);
    inputParser.addRequired('stdX', @isnumeric);
end
inputParser.parse(this, meanX, stdX);

%--------------------------------------------------------------------------

sizeData = size(this.Data);
sizeMean = size(meanX);
sizeStd = size(stdX);
errorId = [class(this), 'destdize'];

assert( ...
    isscalar(meanX) || (ndims(this.Data)==ndims(meanX) && all(sizeData(2:end)==sizeMean(2:end))), ...
    errorId, ...
    'Dimension mismatch between input time series and mean.' ...
);

assert( ...
    isscalar(stdX) || (ndims(this.Data)==ndims(stdX) && all(sizeData(2:end)==sizeStd(2:end))), ...
    errorId, ... 
    'Dimension mismatch between input time series and std deviation.' ...
)

this = unop(@numeric.destdize, this, 0, meanX, stdX);

end%

