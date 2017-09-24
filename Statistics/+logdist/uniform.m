function fn = uniform(lo, hi)
% uniform  Create function proportional to log of uniform distribution.
%
% Syntax
% =======
%
%     fn = logdist.uniform(lo, hi)
%
%
% Input arguments
% ================
%
% * `lo` [ numeric ] - Lower bound of the uniform distribution.
%
% * `hi` [ numeric ] - Upper bound of the uniform distribution.
%
%
% Output arguments
% =================
%
% * `fn` [ function_handle ] - Handle to a function returning a value that
% is proportional to the log of the uniform density.
%
%
% Description
% ============
%
% See [help on the logdisk package](logdist/Contents) for details on
% using the function handle `F`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if lo>hi
    [lo, hi] = deal(hi, lo);
end

mu = 1/2*(lo + hi);
sgm = sqrt(1/12*(hi - lo)^2);
mode = mu;

fn = @(x, varargin) fnUniform(x, lo, hi, mu, sgm, mode, varargin{:});

end




function y = fnUniform(x, a, b, mean_, std_, mode_, varargin)
y = zeros(size(x));
ix = x>=a & x<=b;
y(~ix) = -Inf;
if isempty(varargin)
    return
end
switch lower(varargin{1})
    case {'proper', 'pdf'}
        y(ix) = 1/(b - a);
        y(~ix) = 0;
    case 'info'
        y(ix) = 0;
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
        y = 'uniform';
    case {'rand', 'draw'}
        y = a + (b-a)*rand(varargin{2:end});
    case 'lower'
        y = a;
    case 'upper'
        y = b;
end
end
