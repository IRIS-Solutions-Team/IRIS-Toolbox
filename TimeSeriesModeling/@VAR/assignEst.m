function [this, datFitted] = assignEst(this, s, ixFixedEff, iLoop, opt)
% assignEst  Assign estimated coefficient to VAR object
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ixFixedEffConst = ixFixedEff(1);
ixFixedEffX = ixFixedEff(2:end);
A = s.A;
G = s.G;
Omg = s.Omg;
Sgm = s.Sgm;
ci = s.ci;
resid = s.resid;
ny = size(A, 1);
ng = size(G, 2);
numGroups = max(1, this.NumGroups);

p = s.order; 
if opt.Diff
    p = p - 1;
end

if opt.Intercept
    K = s.K;
    if ~ixFixedEffConst && numGroups>1
        % No fixed effect in panel regression; repeat the estimated constant vector
        % for all groups.
        K = repmat(K, 1, numGroups);
    end
else
    K = zeros(ny, numGroups);
end

% Add the user-imposed mean to the VAR process.
if ~isempty(opt.Mean)
    m = opt.Mean;
    if numGroups>1
        m = repmat(m, 1, numGroups);
    end
    K = K + (eye(ny) - sum(reshape(A, ny, ny, p), 3))*m;
end

% Extract coefficients at exogenous variables, and expand those with no
% fixed effect.
J = s.J;
if ~any(ixFixedEffX)
    J = repmat(J, 1, numGroups);
elseif numGroups>1
    kx = length(this.ExogenousNames);
    jay = cell(1, kx);
    for i = 1 : kx
        if ixFixedEffX(i)
            jay{i} = J(:, 1:numGroups, :);
            J(:, 1:numGroups, :) = [ ];
        else
            jay{i} = repmat(J(:, 1, :), 1, numGroups);
            J(:, 1, :) = [ ];
        end
    end
    % Rearrange coefficients so that J = [ x1-g1, x2-g1, x1-g2, x2-g2 ].
    J = zeros(ny, kx*numGroups);
    for i = 1 : kx
        J(:, i:kx:end) = jay{i};
    end
end

% Convert VEC to co-integrated VAR.
if opt.Diff
    % Add the constant from the co-integrating vector to the constant vector.
    if ng>0
        L = G*ci(:, 1);
        if numGroups>1
            L = repmat(L, 1, numGroups);
        end
        K = K + L;
    end
    A = reshape(A, ny, ny, p);
    A = polyn.prod(A, cat(3, eye(ny), -eye(ny)));
    A = polyn.sum(A, eye(ny)+G*ci(:, 2:end));
    p = p + 1;
    A = reshape(A, ny, ny*p);
end

this.A(:, :, iLoop) = A;
this.K(:, :, iLoop) = K;
this.J(:, :, iLoop) = J;
this.G(:, :, iLoop) = G;
this.Omega(:, :, iLoop) = Omg;
this.Sigma(:, :, iLoop) = Sgm;

% Index of periods fitted. Remove a total of `p` extra NaNs at the end of
% data matrices (introduced because of panel VARs, but added in all VARs).
ixFitted = all(~isnan(resid), 1);
if numGroups>1
    n = length(ixFitted)/numGroups;
    ixFitted = reshape(ixFitted, n, numGroups);
    ixFitted = ixFitted.';
end
ixFitted(:, end-p+1:end, :) = [ ];
this.IxFitted(:, :, iLoop) = ixFitted;

datFitted = cell(numGroups, 1);
for iGrp = 1 : numGroups
    iFitted = ixFitted(iGrp, :);
    datFitted{iGrp} = this.Range(iFitted);
end

end%

