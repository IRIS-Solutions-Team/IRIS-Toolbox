function N = nnzcond(This)
% nnzcond  Number of conditioning data points.
%
%
% Syntax
% =======
%
%     N = nnzcond(P)
%
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of conditioning data points; each variable at
% each date counts as one data point.
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

N = nnz(This.CAnch);

end
