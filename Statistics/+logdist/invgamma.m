function F = invgamma(Mean,Std)
% invgamma  Create function proportional to log of inv-gamma distribution.
%
% Syntax
% =======
%
%     F = logdist.invgamma(MEAN,STD)
%
% Input arguments
% ================
%
% * `MEAN` [ numeric ] - Mean of the inv-gamma distribution.
%
% * `STD` [ numeric ] - Std dev of the inv-gamma distribution.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of the inv-gamma density.
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

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = 2 + (Mean/Std)^2;
b = Mean*(a - 1);
mode = b/(a + 1);
F = @(x,varargin) xxInvGamma(x,a,b,Mean,Std,mode,varargin{:});

end

% Subfunctions.

%**************************************************************************
function Y = xxInvGamma(X,A,B,Mean,Std,Mode,varargin)

Y = zeros(size(X));
inx = X > 0;
X = X(inx);
if isempty(varargin)
    Y(inx) = (-A-1)*log(X) - B./X;
    Y(~inx) = -Inf;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y(inx) = B^A/gamma(A)*(1./X).^(A+1).*exp(-B./X);
    case 'info'
        Y(inx) = -(X*(A + 1) - 2*B) ./ X.^3;
    case {'a','location'}
        Y = A;
    case {'b','scale'}
        Y = B;
    case 'mean'
        Y = Mean;
    case {'sigma','sgm','std'}
        Y = Std;
    case 'mode'
        Y = Mode;
    case 'name'
        Y = 'invgamma';
    case 'draw'
        Y = 1./gamrnd(A,1/B,varargin{2:end});
end

end % xxInvGamma().
