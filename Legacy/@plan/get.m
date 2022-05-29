function varargout = get(this,varargin)
% get  Query to plan object.
%
% Syntax
% =======
%
%     Ans = get(P,Query)
%     [Ans,Ans,...] = get(P,Query,Query,...)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan object.
%
% * `Query` [ char ] - Name of the queried property.
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer.
%
% Valid queries to plan objects
% ==============================
%
% * `'endogenised='` - Returns [ struct ] a database with time series for
% each shock with 1 in each period where the variable is endogenised,
% and 0 in each period where the variable is not endogenised.
%
% * `'exogenised='` - Returns [ struct ] a database with time series for
% each measurement and transition variable with 1 in each period where the
% variable is exogenised, and 0 in each period where the variable is not
% exogenised.
%
% * `'onlyEndogenised='` - Returns [ struct ] the same database as
% `'endogenised='` but including only those shocks that are endogenised at
% least in one period.
%
% * `'onlyExogenised='` - Returns [ struct ] the same database as
% `'exogenised='` but including only those measurement and transition
% variables that are endogenised at least in one period.
%
% * `'range='` - Returns [ numeric ] the simulation plan range.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@iris.mixin.GetterSetter(this,varargin{:});

end
