function fn_ = gamma(mean_, std_)
% gamma  Create function proportional to log of gamma distribution.
%
% Syntax
% =======
%
%     F = logdist.gamma(Mean,Std)
%
%
% Input arguments
% ================
%
% * `mean_` [ numeric ] - Mean of the gamma distribution.
%
% * `std_` [ numeric ] - Std dev of the gamma distribution.
%
%
% Output arguments
% =================
%
% * `fn` [ function_handle ] - Function handle returning a value
% proportional to the log of the gamma density.
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

b = std_^2/mean_;
a = mean_/b;
if a>=1
    mode_ = (a - 1)*b;
else
    mode_ = NaN;
end
fn_ = @(x, varargin) logdist.fnGamma(x, a, b, mean_, std_, mode_, varargin{:});

end
