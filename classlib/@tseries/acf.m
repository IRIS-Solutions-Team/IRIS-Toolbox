function [C,R] = acf(varargin)
% acf  Sample autocovariance and autocorrelation functions.
%
%
% Syntax
% =======
%
%     [C,R] = acf(X)
%     [C,R] = acf(X,Dates,...)
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object.
%
% * `Dates` [ numeric | Inf ] - Dates or date range from which the input
% tseries data will be used.
%
%
% Output arguments
% =================
%
% * `C` [ numeric ] - Auto-/cross-covariance matrices.
%
% * `R` [ numeric ] - Auto-/cross-correlation matrices.
%
%
% Options
% ========
%
% * `'demean='` [ *`true`* | `false` ] - Remove mean from the data before
% computing the ACF.
%
% * `'order='` [ numeric | *`0`* ] - Order up to which the ACF will be
% computed.
%
% * `'smallSample='` [ *`true`* | `false` ] - Adjust degrees of freedom for
% small samples.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

[This,Dates,varargin] = irisinp.parser.parse('tseries.acf',varargin{:});
opt = passvalopt('tseries.acf',varargin{:});

%--------------------------------------------------------------------------

data = mygetdata(This,Dates);

if ndims(data) > 3
    data = data(:,:,:);
end

C = covfun.acovfsmp(data,opt);
if nargout>1
    R = covfun.cov2corr(C);
end

end
