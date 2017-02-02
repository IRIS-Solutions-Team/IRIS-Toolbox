function fn = lognormal(mean_, std_)
% lognormal  Create function proportional to log of log-normal distribution.
%
% Syntax
% =======
%
%     F = logdist.lognormal(Mean,Std)
%
%
% Input arguments
% ================
%
% * `Mean` [ numeric ] - Mean of the log-normal distribution.
%
% * `Std` [ numeric ] - Std dev of the log-normal distribution.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of the log-normal density.
%
% Description
% ============
%
% See [help on the logdisk package](logdist/Contents) for details on
% using the function handle `F`.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = log(mean_^2/sqrt(std_^2 + mean_^2));
b = sqrt(log(std_^2/mean_^2 + 1));
mode = exp(a - b^2);
fn = @(x,varargin) fnLogNormal(x,a,b,mean_,std_,mode,varargin{:});

end




function y = fnLogNormal(x, a, b, mean_, std_, mode_, varargin)
y = zeros(size(x));
ixPositive = x>0;
x = x(ixPositive);
if isempty(varargin)
    logx = log(x);
    y(ixPositive) = -0.5 * ((logx - a)./b).^2  - logx;
    y(~ixPositive) = -Inf;
    return
end
switch lower(varargin{1})
    case {'proper', 'pdf'}
        y(ixPositive) = ...
            1/(b*sqrt(2*pi)) .* exp(-(log(x)-a).^2/(2*b^2)) ./ x;
    case 'info'
        y(ixPositive) = (b^2 + a - log(x) + 1)./(b^2*x.^2);
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
        y = 'lognormal';
    case 'draw'
        y = exp(a + b*randn(varargin{2:end}));
end
end

