function [T, R, k, Z, H, d, U, Zb, inxV, inxW, numUnitRoots, inxInit] = getIthKalmanSystem(this, ~, requiredForward)

numXi = this.NumXi;
numXib = this.NumXib;
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

if all(isnan(U(:)))
    U = [ ];
else
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
inxInit = true(numXi, 1);

end%

