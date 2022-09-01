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

    numXi = ny * p;
    A = zeros(numXi, numXi, nv);
    for v = 1 : nv
        A(:, :, v) = [this.A(:, :, v); eye(ny*(p-1), numXi)];
    end

    [this.T, this.U, this.EigVal, this.EigenStability] = iris.mixin.Kalman.schur(A, this.Tolerance.Eigen);

end%

