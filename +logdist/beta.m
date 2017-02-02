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
% * `F` [ function_handle ] - Function handle returning a value
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = (1-mean_)*mean_^2/std_^2 - mean_;
b = a*(1/mean_ - 1);
if a > 1 && b > 1
    mode = (a - 1)/(a + b - 2);
else
    mode = NaN;
end
fn = @(x,varargin) fnBeta(x,a,b,mean_,std_,mode,varargin{:});

end




function Y = fnBeta(x, a, b, mean_, std_, mode_, varargin)
Y = zeros(size(x));
inx = x>0 & x<1;
x = x(inx);
if isempty(varargin)
    Y(inx) = (a-1)*log(x) + (b-1)*log(1-x);
    Y(~inx) = -Inf;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y(inx) = x.^(a-1).*(1-x).^(b-1)/beta(a,b);
    case 'info'
        Y(inx) = -(b - 1)./(x - 1).^2 - (a - 1)./x.^2;
    case {'a','location'}
        Y = a;
    case {'b','scale'}
        Y = b;
    case 'mean'
        Y = mean_;
    case {'sigma','sgm','std'}
        Y = std_;
    case 'mode'
        Y = mode_;
    case 'name'
        Y = 'beta';
    case 'draw'
        Y = betarnd(a,b,varargin{2:end});
end
end % xxBeta( )
