function This = swap(This,ExogList,EndogList,Dates,varargin)
% swap  Swap endogeneity and exogeneity of variables and shocks.
%
% Syntax
% =======
%
%     P = swap(P,ExogList,EndogList,Dates)
%     P = swap(P,ExogList,EndogList,Dates,Sigma)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `ExogList` [ cellstr | char ] - List of variables that will be
% exogenized.
%
% * `EndogList` [ cellstr | char ] - List of shocks that will be
% endogenized.
%
% * `Dates` [ numeric ] - Dates at which the variables and shocks will be
% exogenized/endogenized.
%
% * `Sigma` [ numeric ] - Anticipation mode (real or imaginary) for the
% endogenized shocks, and their numerical weight (used in underdetermined
% simulation plans); if omitted, `Sigma = 1`.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on exogenized
% variables and endogenized shocks included.
%
% Description
% ============
%
% The function `swap` is equivalent to the following separate calls to
% functions `exogenize` and `endogenize`:
%
%     p = exogenize(p,ExogList,Dates);
%     p = endogenize(p,EndogList,Dates);
%
% or
%
%     p = exogenize(p,ExogList,Dates);
%     p = endogenize(p,EndogList,Dates,Sigma);
%
% if the input argument `Sigma` is provided.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

%--------------------------------------------------------------------------

This = exogenize(This,ExogList,Dates);
This = endogenize(This,EndogList,Dates,varargin{:});

end
