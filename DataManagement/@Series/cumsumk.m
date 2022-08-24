function this = cumsumk(this, range, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addRequired(pp, 'TimeSeries', @(x) isa(x, 'Series'));
    addRequired(pp, 'Range', @validate.properRange);
    addParameter(pp, 'K', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x==round(x)));
    addParameter(pp, 'Rho', 1, @(x) isnumeric(x) && isscalar(x));
    addParameter(pp, 'Log', false, @(x) islogical(x) && isscalar(x));
    addParameter(pp, 'NaNInit', 0, @isnumeric);
end
opt = parse(pp, this, range, varargin{:});

if isequal(opt.K, @auto)
    freqOfInput = dater.getFrequency(this.Start);
    opt.K = -max(1, freqOfInput);
end

if opt.K==0
    return
end

range = double(range);

%--------------------------------------------------------------------------

start = range(1);
extStart = start + min(0, opt.K); 
extEnd = range(end) + max(0, opt.K); 
data = getDataFromTo(this, extStart, extEnd);

sizeData = size(data);
ndimsData = ndims(data);
data = data(:, :);

if opt.Log
    data = log(data);
end

data = series.cumsumk(data, opt.K, opt.Rho, opt.NaNInit);

if opt.Log
    data = exp(data);
end

if ndimsData>2
    sizeData(1) = size(data, 1);
    data = reshape(data, sizeData);
end
this = fill(this, data, start);

end%

