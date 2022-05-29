function N = nnzexog(This)
% nnzexog  Number of exogenised data points.
%
%
% Syntax
% =======
%
%     N = nnzexog(P)
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
%
% * `N` [ numeric ] - Number of exogenised data points; each variable at
% each date counts as one data point.
%
%
% Description
% ============
%
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

N = nnz(This.XAnch);

end
