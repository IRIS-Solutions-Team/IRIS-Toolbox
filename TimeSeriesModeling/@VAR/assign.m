function this = assign(this, A, K, J, Omg, Fitted)
% assign  Manually assign system matrices to VAR object.
%
%
% Syntax
% =======
% 
%     V = assign(V, A, K, J, Omg)
%     V = assign(V, A, K, J, Omg, Dates)
%
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object with variable names.
%
% * `A` [ numeric ] - Transition matrices; see Description.
%
% * `K` [ numeric | empty ] - Constant vector or matrix; if empty, the
% constant vector will be set to zeros, and will not be included in the
% number of free parameters.
%
% * `J` [ numeric | empty ] - Coefficient matrix in front exogenous inputs;
% if empty the matrix will be set to zeros.
%
% * `Omg` [ numeric ] - Covariance matrix of forecast errors (reduced-form
% residuals).
%
% * `Dates` [ numeric ] - Vector of dates of (hypothetical) fitted
% observations; may be omitted.
%
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with system matrices assigned.
%
%
% Description
% ============
%
% To assign matrices for a order-th order VAR, stack the transition
% matrices for individual lags horizontally, 
%
%     A = [A1, ..., Ap]
%
% where `A1` is the coefficient matrix on the first lag, and `Ap` is the
% coefficient matrix on the last, order-th, lag.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    if isnumeric(Fitted)
        Fitted = {Fitted(:).'};
    end
    x = [Fitted{:}];
    xRange = min(x) : max(x);
catch
    Fitted = { };
    xRange = zeros(1, 0);
end

%--------------------------------------------------------------------------

A = A(:, :, :);

ny = length(this.EndogenousNames);
nx = length(this.ExogenousNames);
numGroups = max(1, this.NumGroups);
nv = countVariants(this);
nXPer = length(xRange);
ng = 0;
order = size(A, 2) / ny;
numFree = order*ny*ny;

this = preallocate(this, ny, order, nXPer, nv, ng);
this = assign@BaseVAR(this, A, Omg, xRange, Fitted);

if isempty(K)
    this.K = zeros(ny, numGroups, nv);
elseif size(K, 1) ~= ny || size(K, 2) ~= numGroups || size(K, 3) ~= nv
    utils.error('VAR:assign', ...
        'Invalid size of the constant matrix K.');
else
    this.K = K;
    numFree = numFree + ny;
end

if isempty(J)
    this.J = zeros(nx, numGroups, nv);
elseif size(J, 1)~=ny || size(J, 2)~=nx*numGroups || size(J, 3)~=nv
    utils.error('VAR:assign', ...
        'Invalid size of the coefficient matrix J.');
else
    this.J = J;
    numFree = numFree + ny*nx;
end

this.G = zeros(ny, 0);
this.Zi = zeros(0, ny*order+1);
this.NHyper = numFree;

this = schur(this);
this = infocrit(this);

end%

