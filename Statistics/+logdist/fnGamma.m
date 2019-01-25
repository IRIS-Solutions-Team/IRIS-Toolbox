function y = fnGamma(x, a, b, mean_, std_, mode_, varargin)
% fnGamma  Backend gamma distribution function to support gamma, inv gamma, and chi2.
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

% A: shape
% B: scale

%--------------------------------------------------------------------------

y = zeros(size(x));
ix = x>0;
x = x(ix);
if isempty(varargin)
    y(ix) = (a-1)*log(x) - x/b;
    y(~ix) = -Inf;
    return
end

switch lower(varargin{1})
    case {'proper', 'pdf'}
        y(ix) = x.^(a-1).*exp(-x/b) / (b^a*gamma(a));
    case 'info'
        y(ix) = (a - 1)/x.^2;
        y(~ix) = NaN;
    case {'a', 'location'}
        y = a;
    case {'b', 'scale'}
        y = b;
    case 'mean'
        y = mean_;
    case {'sigma', 'sgm', 'std'}
        y = std_;
    case 'mode'
        y = mode_;
    case 'name'
        y = 'gamma';
    case {'rand', 'draw'}
        y = gamrnd(a, b, varargin{2:end});
    case 'lower'
        y = 0;
    case 'upper'
        y = Inf;
end

end
