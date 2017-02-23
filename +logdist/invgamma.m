function fn = invgamma(mean_, std_)
% invgamma  Create function proportional to log of inv-gamma distribution.
%
% Syntax
% =======
%
%     fn = logdist.invgamma(mean, stdev)
%
%
% Input arguments
% ================
%
% * `mean` [ numeric ] - Mean of the inv-gamma distribution.
%
% * `stdev` [ numeric ] - Stdev of the inv-gamma distribution.
%
%
% Output arguments
% =================
%
% * `fn` [ function_handle ] - Function handle returning a value
% proportional to the log of the inv-gamma density.
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

a = 2 + (mean_/std_)^2;
b = mean_*(1 + (mean_/std_)^2);
mode = b/(a + 1);
fn = @(x,varargin) fnInvGamma(x, a, b, mean_, std_, mode, varargin{:});

end




function y = fnInvGamma(x, a, b, mean_, std_, mode_, varargin)
y = zeros(size(x));
ix = x>0;
x = x(ix);
if isempty(varargin)
    y(ix) = (-a-1)*log(x) - b./x;
    y(~ix) = -Inf;
    return
end
switch lower(varargin{1})
    case {'proper', 'pdf'}
        y(ix) = b^a/gamma(a)*(1./x).^(a+1).*exp(-b./x);
    case 'info'
        y(ix) = (2*b - x*(a + 1))./x.^3;
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
        y = 'invgamma';
    case {'rand', 'draw'}
        y = 1./gamrnd(a, 1/b, varargin{2:end});
    case 'lower'
        y = 0;
    case 'upper'
        y = Inf;
end
end
