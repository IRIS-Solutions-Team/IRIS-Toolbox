
function this = destdize(this, meanX, stdX)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.addRequired('inputSeries', @(x) isa(x, 'Series'));
    ip.addRequired('meanX', @isnumeric);
    ip.addRequired('stdX', @isnumeric);
end
parse(ip, this, meanX, stdX);


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

    this = unop(@series.destdize, this, 0, meanX, stdX);

end%

