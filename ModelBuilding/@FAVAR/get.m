function varargout = get(this,varargin)
% get  Query model object properties.
%
% Syntax
% =======
%
%     Ans = get(A,Query)
%     [Ans,Ans,...] = get(A,Query,Query,...)
%
% Input arguments
% ================
%
% * `A` [ FAVAR ] - FAVAR object.
%
% * `Query` [ char ] - Query to the FAVAR object.
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
% Valid queries to FAVAR objects
% ===============================
%
% System matrices
% -----------------
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
% Underlying VAR
% ----------------
%
% * `'VAR'` Returns [ VAR ] a VAR object describing the factor dynamics.
%
% Eigenvalues and singular values
% ---------------------------------
% 
% * `'eig'` Returns [ numeric ] the vector of eigenvalues of the underlying
% VAR.
%
% * `'sing'` Returns [ numeric ] the vector of singular values from the
% principal component estimation step.
%
% Observables and factors
% -------------------------
%
% * `'mean'` Returns [ numeric ] the estimated mean of the observables used
% to standardise the input data.
%
% * `'std'` Returns [ numeric ] the estimated std deviations of the
% observables used to standardise the input data.
%
% * `'ny'` Returns [ numeric ] the number of observables.
%
% * `'nx'` Returns [ numeric ] the number of factors.
%
% * `'yList'` Returns [ cellstr ] the list of the names of observables.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@shared.GetterSetter(this,varargin{:});

end