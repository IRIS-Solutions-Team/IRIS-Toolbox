function fn = invgamma(mean_, std_, a, b)
% invgamma  Create function proportional to log of square-root-inverse-gamma distribution.
%
% Syntax
% =======
%
%     fn = logdist.invgamma(mean, stdev)
%     fn = logdist.invgamma(NaN, NaN, a, b)
%
%
% Input arguments
% ================
%
% * `mean` [ numeric ] - Mean of the square-root-inverse-gamma distribution.
%
% * `stdev` [ numeric ] - Stdev of the square-root-inverse-gamma distribution.
%
% * `a` [ numeric ] - Parameter alpha defining square-root-inverse-gamma distribution.
%
% * 'b` [ numeric ] - Parameter beta defining square-root-inverse-gamma distribution.
%
%
% Output arguments
% =================
%
% * `fn` [ function_handle ] - Function handle returning a value
% proportional to the log of the square-root-inverse-gamma density.
%
%
% Description
% ============
%
% See [help on the logdisk package](logdist/Contents) for details on
% using the function handle `fn`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequaln(mean_, NaN) && isequaln(std_, NaN)
    mean_ = sqrt(b)*exp(gammaln(a-.5)-gammaln(a));
    if a>1
        std_ = sqrt(b/(a-1)-mean_^2);
    else
        std_ = Inf;
    end 
elseif isinf(std_)
    a = 1;
    b = mean_^2/pi;
else
    %a = fzero(@(x) gammaln(x)-gammaln(x-.5)-log((x-1)*(1+(std_/mean_)^2))/2,[1+eps 1e3]);
    a = fzero(@(x) 0.5*(log(std_^2+mean_^2)+log(x-1)) + gammaln(x-0.5) - gammaln(x) - log(mean_), [1+eps 1e3]);
    b = (a-1)*(mean_^2+std_^2);
end
mode_ = sqrt((a-.5)/b);
fn = @(x,varargin) fnInvGamma(x, a, b, mean_, std_, mode_, varargin{:});

end




function y = fnInvGamma(x, a, b, mean_, std_, mode_, varargin)
y = zeros(size(x));
ix = x>0;
x = x(ix);
if isempty(varargin)
    y(ix) = (-2*a-1)*log(x) - b./x.^2 + log(2) - gammaln(a) + a*log(b);
    y(~ix) = -Inf;
    return
end
switch lower(varargin{1})
    case {'proper', 'pdf'}
        y(ix) = 2*b^a/gamma(a)*x.^(-2*a-1).*exp(-b./x.^2);
    case 'info'
        y(ix) = (6*b - x.^2*(2*a + 1))./x.^4;
        y(~ix) = NaN;
    case {'a', 'shape'}
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
        y = 'invgamma1';
    case {'rand', 'draw'}
        y = 1./sqrt(gamrnd(a, 1/b, varargin{2:end}));
    case 'lower'
        y = 0;
    case 'upper'
        y = Inf;
end
end
