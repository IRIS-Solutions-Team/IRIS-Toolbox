function varargout = get(This,varargin)
% get  Query SVAR object properties.
%
% Syntax
% =======
%
%     Ans = get(V,Query)
%     [Ans,Ans,...] = get(V,Query,Query,...)
%
% Input arguments
% ================
%
% * `V` [ SVAR ] - SVAR object.
%
% * `Query` [ char ] - Query to the SVAR object.
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
% Valid queries to SVAR objects
% ==============================
%
% All queries to VAR objects, listed and described in [`VAR/get`](VAR/get),
% can also be used in SVAR objects. In addition, the following queries are
% specific to SVAR objects:
%
% * `'B'` - Returns [ numeric ] matrix of instantaneous effects of shocks.
%
% * `'std'` - Returns [ numeric ] std deviation of structural shocks.
%
% * `'method'` - Returns [ char ] identification method used to convert
% reduced-form VAR to structural VAR.
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

[varargout{1:nargout}] = get@iris.mixin.GetterSetter(This,varargin{:});

end
