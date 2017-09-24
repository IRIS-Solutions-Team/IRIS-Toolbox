function [q, dim] = quantile(x, w, tau, varargin{:})
% tilting.quantile  Quantiles of possibly weighted observations
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Q = tilting.quantile(X, W, Tau, ~Dim)
%
%
% __Input Arguments__
%
% * `X` [ numeric ] - Arrays with input observations.
%
% * `W` [ numeric | empty ] - Vector of weights whose dimension must match
% `size(X, Dim)`; if empty, all observations are given an equal weight.
%
% * `Tau` [ numeric ] - Vector of quantiles (between 0 and 1) to be
% calculated.
%
% * `~Dim` [ numeric ] - Dimension along which the quantiles will be
% calculated; if omitted, `Dim=2`.
%
%
% __Output Arguments__
%
% * `Q` [ numeric ] - Quantiles of input observations.
%
%
% __Description__
%
%
% __Examples__
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isnumeric(tau)
    switch lower(char(tau))
    case 'quartiles'
        tau = [0.25, 0.5, 0.75];
    case 'deciles'
        tau = 0.10 : 0.10 : 0.90;
    end
end

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tilting/quantile');
    INPUT_PARSER.addRequired('InputData', @(x) isnumeric(x) || isa(x, 'series.Abstract'));
    INPUT_PARSER.addRequired('Weights', @isnumeric);
    INPUT_PARSER.addRequired('Tau', @(x) isnumeric(x) && all(x(:)>0 & x(:)<1));
    INPUT_PARSER.addOptional('Dim', @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>=1);
end
INPUT_PARSER.parse(x, w, tau, varargin{:});
dim = INPUT_PARSER.Results.Dim;

if isa(x, 'series.Abstract')
    [x, dim] = applyFunctionAlongDim(x, @tilting.quantile, w, tau, dim);
    return
end

%--------------------------------------------------------------------------

if isempty(tau)
    sizeOfInputData = size(x);
    if dim>length(sizeOfInputData)
        sizeOfInputData(end+1:dim) = 1;
    end
    sizeOfInputData(dim) = 0;
    q = zeros(sizeOfInputData);
    return
end

if ~isempty(w) && all(w(1)==w)
    w = [ ];
end

tau = tau(:);
numOfQuantiles = numel(tau);

% Put dim-th dimension first, and unfold higher dimensions into 2D (so that x
% is a 2D matrix).
[x, shape] = tilting.reshape(x, dim, 2);
numOfRows = size(x, 1);

[xs, pos] = sort(x, 1);
if isempty(w)
    grid = ((0:numOfRows-1) + (1:numOfRows)) / (2*numOfRows);
    grid = grid(:);
    q = interp1([0; grid; 1], [xs(1, :); xs; xs(end, :)], tau, 'linear');
else
    numOfColumns = size(x, 2);
    q = nan(numOfQuantiles, numOfColumns);
    for i = 1 : numOfColumns
        wi = w(pos(:, i));
        cumw = cumsum(wi(:), 1);
        grid = ([0; cumw(1:end-1)] + cumw) / (2*cumw(end));
        q(:, i) = interp1([0; grid; 1], [xs(1, i); xs(:, i); xs(end, i)], tau, 'linear');
    end
end

q = tilting.reshape(q, shape);

end
