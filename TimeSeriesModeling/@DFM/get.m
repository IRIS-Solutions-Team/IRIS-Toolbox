function varargout = get(this, varargin)
% get  Query model object properties.
%
% __Syntax__
%
%     Ans = get(A, Query)
%     [Ans, Ans, ...] = get(A, Query, Query, ...)
%
%
% __Input Arguments__
%
% * `A` [ DFM ] - DFM object.
%
% * `Query` [ char ] - Query to the DFM object.
%
%
% __Output Arguments__
%
% * `Ans` [ ... ] - Answer to the query.
%
%
% __Valid Queries to DFM Objects__
%
% _System Matrices_
%
% * `'A*'` Returns [ numeric ] the transition matrix of the underlying VAR
% system on factors.
%
% * `'B'` Returns [ numeric ] tne matrix mapping the impact of structural
% residuals on the factors in the underlying VAR.
%
% * `'C'` Returns [ numeric ] the matrix mapping the factors into the
% observables.
%
% * `'Omega'` Returns [ numeric ] the reduced-form covariance matrix of
% the residuals in the underlying VAR.
%
% * `'Sigma'` Returns [ numeric ] the covariance matrix of idiosyncratic
% shocks.
%
%
% _Underlying VAR_
%
% * `'VAR'` Returns [ VAR ] a VAR object describing the factor dynamics.
%
%
% _Eigenvalues and Singular Values_
% 
% * `'eig'` Returns [ numeric ] the vector of eigenvalues of the underlying
% VAR.
%
% * `'sing'` Returns [ numeric ] the vector of singular values from the
% principal component estimation step.
%
%
% _Observables and Factors_
%
% * `'mean'` Returns [ numeric ] the estimated mean of the observables used
% to standardize the input data.
%
% * `'std'` Returns [ numeric ] the estimated std deviations of the
% observables used to standardize the input data.
%
% * `'ny'` Returns [ numeric ] the number of observables.
%
% * `'nx'` Returns [ numeric ] the number of factors.
%
% * `'yList'` Returns [ cellstr ] the list of the names of observables.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@iris.mixin.GetterSetter(this, varargin{:});

end
