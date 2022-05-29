function this = backward(this)
% backward  Backward VAR process.
%
% Syntax
% =======
%
%     B = backward(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `B` [ VAR ] - VAR object with the VAR process reversed in time.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nv = size(this.A, 3);

indexStationary = isstationary(this);
for v = 1 : nv
    if indexStationary(v)
        [T, R, ~, ~, ~, ~, U, Omega] = sspace(this, v);
        eigenStability = this.EigenStability(:, :, v);
        indexUnitRoots = eigenStability==1;
        % 0th and 1st order autocovariance matrices of stacked y vector.
        C = covfun.acovf(T, R, [ ], [ ], [ ], [ ], U, Omega, indexUnitRoots, 1);
        oldA = this.A(:, :, v);
        newA = transpose(C(:, :, 2)) / C(:, :, 1);
        Q = newA*C(:, :, 2);
        Omega = C(:, :, 1) + newA*C(:, :, 1)*transpose(newA) - Q - transpose(Q);
        newA = newA(end-ny+1:end, :);
        newA = reshape(newA, ny, ny, p);
        newA = newA(:, :, end:-1:1);
        newA = newA(:, :);
        this.A(:, :, v) = newA;
        this.Omega(:, :, v) = Omega(end-ny+1:end, end-ny+1:end);
        R = sum(polyn.var2polyn(newA), 3) / sum(polyn.var2polyn(oldA), 3);
        this.K(:, :, v) = R * this.K(:, :, v);
        this.J(:, :, v) = R * this.J(:, :, v);
    else
        % Non-stationary parameterisations.
        this.A(:, :, v) = NaN;
        this.Omega(:, :, v) = NaN;
        this.K(:, :, v) = NaN;
        this.J(:, :, v) = NaN;
    end
end

assert( ...
    all(indexStationary), ...
    'VAR:backward', ...
    'Cannot compute backward VAR for non-stationary parameterisations %s ', ...
    exception.Base.alt2str(~indexStationary) ...
);

this = schur(this);

end
