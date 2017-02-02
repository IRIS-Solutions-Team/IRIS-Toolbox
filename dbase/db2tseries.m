function [x, list, range] = db2tseries(d, varargin)
% db2tseries  Combine tseries database entries in one multivariate tseries object.
%
% Syntax
% =======
%
%     [X,Incl,Range] = db2tseries(D,List,Range)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database with tseries objects that will be
% combined in one multivariate tseries object.
%
% * `List` [ char | cellstr ] - List of tseries names that will be
% combined.
%
% * `Range` [ numeric | Inf ] - Date range.
%
% Output arguments
% =================
%
% * `X` [ numeric ] - Combined multivariate tseries object.
%
% * `Incl` [ cellstr ] - List of tseries names that have been actually
% found in the database.
%
% * `Range` [ numeric ] - The date range actually used.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[x, list, range] = db2array(d, varargin{:});
x = Series(range, x);

end
