% schur  Compute and store triangular representation of VAR
%
% Syntax
% =======
%
%     V = schur(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR or VAR based object.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with the triangular representation matrices
% re-calculated.
%
% Description
% ============
%
% In most cases, you don't have to run the function `schur` as it is called
% from within `estimate` immediately after a new parameterisation is
% created.
%
% Example
% =======
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = schur(this)

[ny, p, nv] = size(this.A);
p = p / max(ny, 1);

if p==0
    this.T = zeros(ny, ny, nv);
    this.U = repmat(eye(ny), 1, 1, nv);
    this.EigVal = double.empty(1, 0, nv);
    this.EigenStability = int8.empty(1, 0, nv);
    return
end

A = zeros(ny*p, ny*p, nv);
for v = 1 : nv
    A(:, :, v) = [this.A(:, :, v); eye(ny*(p-1), ny*p)];
end

this.U = nan(ny*p, ny*p, nv);
this.T = nan(ny*p, ny*p, nv);
this.EigVal = nan(1, ny*p, nv);
this.EigenStability = zeros(1, ny*p, nv, 'int8');
tolerance = this.Tolerance.Eigen;
for v = 1 : nv
    if any(any(isnan(A(:, :, v))))
        continue
    else
        [U, T] = schur(A(:, :, v));
        eigVal = ordeig(T);
        eigVal = reshape(eigVal, 1, [ ]);
        indexUnstableRoots = abs(eigVal) > 1 + tolerance;
        indexUnitRoots = abs(abs(eigVal) - 1) <= tolerance;
        numUnstableRoots = nnz(indexUnstableRoots);
        numUnitRoots = nnz(indexUnitRoots);
        clusters = zeros(size(eigVal));
        clusters(indexUnstableRoots) = 2; % Unstable roots first
        clusters(indexUnitRoots) = 1; % Unit roots second, stable roots last
        [this.U(:, :, v), this.T(:, :, v)] = ordschur(U, T, clusters);
        orderedEigenValues = ordeig(this.T(:, :, v));
        this.EigVal(1, :, v) = orderedEigenValues;
        this.EigenStability(1, 1:numUnstableRoots, v) = 2;
        this.EigenStability(1, numUnstableRoots+(1:numUnitRoots), v) = 1;
        this.EigenStability(1, numUnstableRoots+numUnitRoots+1:end, v) = 0;
    end
end

end%

