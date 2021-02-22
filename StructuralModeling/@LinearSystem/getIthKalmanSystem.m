function [T, R, k, Z, H, d, U, Zb, inxV, inxW, numUnitRoots, inxInit] = getIthKalmanSystem(this, ~, requiredForward)

numXi = this.NumXi;
numXiB = this.NumXiB;
numV = this.NumV;
numY = this.NumY;
numW = this.NumW;
numE = numV + numW;

[T, R, k, Z, H, d, U, Zb] = this.SystemMatrices{:};

T = this.clipAndFillMissing(T);

R = this.clipAndFillMissing(R);
R = [R, zeros(numXi, numW, size(R, 3))];
if requiredForward>0
    R = [R, zeros(numXi, numE*requiredForward, size(R, 3))];
end

k = this.clipAndFillMissing(k);
k = k(:, :);

Z = this.clipAndFillMissing(Z);

H = this.clipAndFillMissing(H);
H = [zeros(numY, numV, size(H, 3)), H];

d = this.clipAndFillMissing(d);
d = d(:, :);

if isempty(U) || all(isnan(U(:)))
    needsTransform = false;
    U = [ ];
else
    needsTransform = true;
    U = this.clipAndFillMissing(U);
end

if all(isnan(Zb(:)))
    Zb = [ ];
else
    Zb = this.clipAndFillMissing(Zb);
end

inxV = [true(1, numV), false(1, numW)];
inxW = [false(1, numV), true(1, numW)];
numUnitRoots = this.NumUnitRoots;

%
% Necessary initial conditions
%
% Take the transition matrix 0->1 and find the elements of XiB that have
% at least one non-zero entry in that transition matrix
%
T01 = T(:, :, min(2, end));
if any(isnan(T01(:)))
    inxInit = true(numXib, 1);
else
    if needsTransform
        T01 = T01/U;
    end
    inxInit = reshape( any(abs(T01)>this.Tolerance.Solve, 1), [ ], 1 );
end

end%

