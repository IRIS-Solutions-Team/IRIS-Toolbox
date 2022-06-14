function this = destdize(this, meanX, stdX)
% destdize  Destandardize time series by multiplying it by std dev and adding mean
%
% __Syntax__
%
%     x = destdize(x, meanX, stdX)
%
%
% __Input Arguments__
%
% * `x` [ TimeSubscriptable ] - Input TimeSubscriptable object.
%
% * `meanX` [ numeric ] - Mean that will be added the data.
%
% * `stdX` [ numeric ] - Standard deviation that will be added to the data.
%
%
% __Output Arguments__
%
% * `x` [ TimeSubscriptable ] - Destandardized output data.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

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

