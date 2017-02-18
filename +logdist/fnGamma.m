function y = fnGamma(x, a, b, mean_, std_, mode_, varargin)
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% A: shape
% B: scale

%--------------------------------------------------------------------------

y = zeros(size(x));
ixPositive = x>0;
x = x(ixPositive);
if isempty(varargin)
    y(ixPositive) = (a-1)*log(x) - x/b;
    y(~ixPositive) = -Inf;
    return
end

switch lower(varargin{1})
    case {'proper', 'pdf'}
        y(ixPositive) = x.^(a-1).*exp(-x/b)/(b^a*gamma(a));
    case 'info'
        y(ixPositive) = (a - 1)/x.^2;
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
    case 'draw'
        y = gamrnd(a, b, varargin{2:end});
end

end
