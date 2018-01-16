function fn = beta(mean_, std_)
% beta  Create function proportional to log of beta distribution.
%
% Syntax
% =======
%
%     fn = logdist.beta(mean, stdev)
%
%
% Input arguments
% ================
%
% * `mean` [ numeric ] - Mean of the beta distribution.
%
% * `stdev` [ numeric ] - Stdev of the beta distribution.
%
%
% Output arguments
% =================
%
% * `fn` [ function_handle ] - Function handle returning a value
% proportional to the log of the beta density.
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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = (1-mean_)*mean_^2/std_^2 - mean_;
b = a*(1/mean_ - 1);
if a > 1 && b > 1
    mode_ = (a - 1)/(a + b - 2);
else
    mode_ = NaN;
end
fn = @(x, varargin) fnBeta(x, a, b, mean_, std_, mode_, varargin{:});

end




function y = fnBeta(x, a, b, mean_, std_, mode_, varargin)
y = zeros(size(x));
ix = x>0 & x<1;
x = x(ix);
if isempty(varargin)
    y(ix) = (a-1)*log(x) + (b-1)*log(1-x);
    y(~ix) = -Inf;
    return
end
switch lower(varargin{1})
    case {'proper', 'pdf'}
        y(ix) = x.^(a-1).*(1-x).^(b-1) / beta(a, b);
    case 'info'
        y(ix) = (b - 1)./(x - 1).^2 + (a - 1)./x.^2;
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
        y = 'beta';
    case {'rand', 'draw'}
        y = betarnd(a, b, varargin{2:end});
    case 'lower'
        y = 0;
    case 'upper'
        y = 1;
end
end 
