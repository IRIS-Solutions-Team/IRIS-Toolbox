function [q, dim] = quantile(x, w, tau, varargin)
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if ~isnumeric(tau)
    switch lower(char(tau))
    case 'quartiles'
        tau = [0.25, 0.5, 0.75];
    case 'deciles'
        tau = 0.10 : 0.10 : 0.90;
    end
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tilting/quantile');
    inputParser.addRequired('InputData', @(x) isnumeric(x) || isa(x, 'Series'));
    inputParser.addRequired('Weights', @isnumeric);
    inputParser.addRequired('Tau', @(x) isnumeric(x) && all(x(:)>0 & x(:)<1));
    inputParser.addOptional('Dim', 2, @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>=1);
end
inputParser.parse(x, w, tau, varargin{:});
dim = inputParser.Results.Dim;

if isa(x, 'Series')
    [q, dim] = applyFunctionAlongDim(x, @tilting.quantile, w, tau, dim);
    return
end

%--------------------------------------------------------------------------

if isempty(tau)
    sizeInputData = size(x);
    if dim>length(sizeInputData)
        sizeInputData(end+1:dim) = 1;
    end
    sizeInputData(dim) = 0;
    q = zeros(sizeInputData);
    return
end

if ~isempty(w) && all(w(1)==w)
    w = [ ];
end

tau = tau(:);
numQuantiles = numel(tau);

% Put dim-th dimension first, and unfold higher dimensions into 2D (so that x
% is a 2D matrix)
[x, redimStruct] = series.redim(x, dim);
numRows = size(x, 1);

[xs, pos] = sort(x, 1);
if isempty(w)
    xs = sort(x, 1);
    grid = ((0:numRows-1) + (1:numRows)) / (2*numRows);
    grid = grid(:);
    q = interp1([0; grid; 1], [xs(1, :); xs; xs(end, :)], tau, 'linear');
else
    numColumns = size(x, 2);
    q = nan(numQuantiles, numColumns);
    for i = 1 : numColumns
        [ithX, pos] = sort(x(:, i), 1);
        ithW = w(pos);
        ithCumW = cumsum(ithW(:), 1);
        grid = ([0; ithCumW(1:end-1)] + ithCumW) / (2*ithCumW(end));
        q(:, i) = interp1([0; grid; 1], [ithX(1); ithX(:); ithX(end)], tau, 'linear');
    end
end

q = series.redim(q, dim, redimStruct);

end
