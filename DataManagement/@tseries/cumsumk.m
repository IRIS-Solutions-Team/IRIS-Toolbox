function X = cumsumk(X,K,Rho,varargin)
% cumsumk  Cumulative sum with a k-period leap.
%
% Syntax
% =======
%
%     Y = cumsumk(X,K,Rho,Range)
%     Y = cumsumk(X,K,Rho)
%     Y = cumsumk(X,K)
%     Y = cumsumk(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input data.
%
% * `K` [ numeric ] - Number of periods that will be leapt the cumulative
% sum will be taken; if not specified, `K` is chosen to match the frequency
% of the input data (e.g. `K = -4` for quarterly data), or `K = -1` for
% indeterminate frequency.
%
% * `Rho` [ numeric ] - Autoregressive coefficient; if not specified, `Rho
% = 1`.
%
% * `Range` [ numeric ] - Range on which the cumulative sum will be
% computed and the output series returned.
%
% Output arguments
% =================
%
% * `Y` [ tseries ] - Output data constructed as described below.
%
% Options
% ========
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the input data before,
% and de-logarithmise the output data back after, running `x12`.
%
% Description
% ============
%
% If `K < 0`, the first `K` observations in the output series `Y` are
% copied from `X`, and the new observations are given recursively by
%
%     Y{t} = Rho*Y{t-K} + X{t}.
%
% If `K > 0`, the last `K` observations in the output series `Y` are
% copied from `X`, and the new observations are given recursively by
%
%     Y{t} = Rho*Y{t+K} + X{t},
%
% going backwards in time.
%
% If `K == 0`, the input data are returned.
%
% Example
% ========
%
% Construct random data with seasonal pattern, and run X12 to seasonally
% adjust these series.
%
%     x = tseries(qq(1990,1):qq(2020,4),@randn);
%     x1 = cumsumk(x,-4,1);
%     x2 = cumsumk(x,-4,0.7);
%     x1sa = x12(x1);
%     x2sa = x12(x2);
%
% The new series `x1` will be a unit-root process while `x2` will be
% stationary. Note that the command on the second line could be replaced
% with `x1 = cumsumk(x)`.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    K; %#ok<VUNUS>
catch
    K = -max(1,DateWrapper.getFrequencyFromNumeric(X.start));
end         

try
    Rho; %#ok<VUNUS>
catch
    Rho = 1;
end

if ~isempty(varargin) && ~ischar(varargin{1})
    Range = varargin{1};
    varargin(1) = [ ];
else
    Range = Inf;
end

opt = passvalopt('tseries.cumsumk',varargin{:});

if K == 0
    return
end

%--------------------------------------------------------------------------

dataSize = size(X.data);
X.data = X.data(:,:);
[data,range] = rangedata(X,Range);

if opt.log
    data = log(data);
end

data = tseries.mycumsumk(data,K,Rho);

if opt.log
    data = exp(data);
end

X.start = range(1);
if length(dataSize) == 2
    X.data = data;
else
    X.data = reshape(data,[size(data,1),dataSize(2:end)]);
end

end
