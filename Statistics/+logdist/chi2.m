function fn = chi2(df)
% chi2  Create function proportional to log of Chi-Squared distribution.
%
% Syntax
% =======
%
%     fn = logdist.chi2(df)
%
%
% Input arguments
% ================
%
% * `df` [ integer ] - Degrees of freedom of Chi-squared distribution.
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
% using the function handle `F`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = df / 2 ;
b = 2 ;
mean_ = a*b ;
std_ = sqrt(a)*b ;
if a>=1
    mode_ = (a - 1)*b;
else
    mode_ = NaN;
end
fn = @(x, varargin) logdist.fnGamma(x, a, b, mean_, std_, mode_, varargin{:});

end
