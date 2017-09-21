function [q, tau, dim] = qtilew(x, w, tau, dim)
% qtilew  Quantiles of possibly weighted observations.
%
% Syntax
% =======
%
%     q = qtilew(x, w, tau, ~dim)
%
%
% Input arguments
% ================
%
% * `x` [ numeric ] - Arrays with input observations.
%
% * `w` [ numeric | empty ] - Vector of weights whose dimension must match
% `size(x, dim)`; if empty, all observations are given an equal weight.
%
% * `tau` [ numeric ] - Vector of quantiles (between 0 and 1) to be
% calculated.
%
% * `dim` [ numeric ] - Dimension along which the quantiles will be
% calculated; if omitted, `dim=2`.
%
%
% Output arguments
% =================
%
% * `q` [ numeric ] - Quantiles of input observations.
%
%
% Description
% ============
%
%
% Examples
% =========
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

quart = [0.25, 0.5, 0.75];
try, w; catch, w = [ ]; end
try, tau; catch, tau = quart; end
try, dim; catch, dim = 2; end

%--------------------------------------------------------------------------

if isempty(tau)
    size_ = size(x);
    if dim>length(size_)
        size_(end+1:dim) = 1;
    end
    size_(dim) = 0;
    q = zeros(size_);
    return
end

if isequal(tau, @quartiles)
    tau = quart;
end

if ~isempty(w) && all(w(1)==w)
    w = [ ];
end

tau = tau(:);
nTau = numel(tau);

% Put dim-th dimension first, and unfolde higher dimensions into 2D (so that x
% is a 2D matrix).
[x, redim] = statfun.redim(x, dim, 2);
N = size(x, 1);

[xs, pos] = sort(x, 1);
if isempty(w)
    grid = ((0:N-1) + (1:N)) / (2*N);
    grid = grid(:);
    q = interp1([0; grid; 1], [xs(1, :); xs; xs(end, :)], tau, 'linear');
else
    nCol = size(x, 2);
    q = nan(nTau, nCol);
    for i = 1 : nCol
        wi = w(pos(:, i));
        cumw = cumsum(wi(:), 1);
        grid = ([0; cumw(1:end-1)] + cumw) / (2*cumw(end));
        q(:, i) = interp1([0; grid; 1], [xs(1, i); xs(:, i); xs(end, i)], tau, 'linear');
    end
end

q = statfun.redim(q, redim);

end
