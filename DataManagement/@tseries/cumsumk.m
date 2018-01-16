function this = cumsumk(this, varargin)
% cumsumk  Cumulative sum with a k-period leap
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Y = cumsumk(X, ~K, ~Rho, ~Range)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series.
%
% * `~K` [ numeric ] - Number of periods that will be leapt the cumulative
% sum will be taken; if omitted, `K` is chosen to match the frequency of
% the input data (e.g. `K=-4` for quarterly data), or `K=-1` for integer
% frequency.
%
% * `~Rho` [ numeric ] - Autoregressive coefficient; if omitted, `Rho=1`.
%
% * `~Range` [ numeric ] - Range on which the cumulative sum will be
% computed and the output time series returned; if omitted, the entire
% input time series range will be used.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Output time series constructed as described below.
%
%
% __Options__
%
% * `Log=false` [ `true` | `false` ] - Logarithmize the input data before, 
% and de-logarithmize the output data back afterwards.
%
%
% __Description__
%
% If `K<0`, the first `K` observations in the output series are copied from
% the input series, and the new observations are given recursively by
%
%     Y{t} = Rho*Y{t-K} + X{t}.
%
% If `K>0`, the last `K` observations in the output series are copied from
% the input series, and the new observations are given recursively by
%
%     Y{t} = Rho*Y{t+K} + X{t}, 
%
% going backwards in time.
%
% If `K == 0`, the input data are returned.
%
% __Example__
%
% Construct random data with seasonal pattern, and run X12 to seasonally
% adjust these series.
%
%     x = tseries(qq(1990, 1):qq(2020, 4), @randn);
%     x1 = cumsumk(x, -4, 1);
%     x2 = cumsumk(x, -4, 0.7);
%     x1sa = x12(x1);
%     x2sa = x12(x2);
%
% The new series `x1` will be a unit-root process while `x2` will be
% stationary. Note that the command on the second line could be replaced
% with `x1 = cumsumk(x)`.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries.cumsumk');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
    INPUT_PARSER.addParameter('K', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x==round(x)));
    INPUT_PARSER.addParameter('Rho', 1, @(x) isnumeric(x) && isscalar(x));
    INPUT_PARSER.addParameter('Log', false, @(x) islogical(x) && isscalar(x));
end
INPUT_PARSER.parse(this, varargin{:});
range = INPUT_PARSER.Results.Range;
opt = INPUT_PARSER.Options;

if isequal(opt.K, @auto)
    opt.K = -max(1, DateWrapper.getFrequencyFromNumeric(this.Start));
end

if opt.K==0
    return
end

%--------------------------------------------------------------------------

[data, range] = getData(this, range);
sizeData = size(data);
ndimsData = ndims(data);
data = data(:, :);

if opt.Log
    data = log(data);
end

data = numeric.cumsumk(data, opt.K, opt.Rho);

if opt.Log
    data = exp(data);
end

this.Start = range(1);
if ndimsData>2
    sizeData(1) = size(data, 1);
    data = reshape(data, sizeData);
end
this.Data = data;

this = trim(this);

end
