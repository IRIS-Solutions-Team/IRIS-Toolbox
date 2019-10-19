function [T, R, k, Z, H, d, U, Zb, inxV, inxW, numUnitRoots, inxInit] = getIthKalmanSystem(this, ~, requiredForward)

nxi = this.NumXi;
nv  = this.NumV;
ny  = this.NumY;
nw  = this.NumW;
ne = nv + nw;

[T, R, k, Z, H, d, U, Zb] = this.SystemMatrices{:};

T = this.clipAndFillMissing(T);

R = this.clipAndFillMissing(R);
R = [R, zeros(nxi, nw, size(R, 3))];
if requiredForward>0
    R = [R, zeros(nxi, ne*requiredForward, size(R, 3))];
end

k = this.clipAndFillMissing(k);
k = k(:, :);

Z = this.clipAndFillMissing(Z);

H = this.clipAndFillMissing(H);
H = [zeros(ny, nv, size(H, 3)), H];

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

inxV = [true(1, nv), false(1, nw)];
inxW = [false(1, nv), true(1, nw)];
numUnitRoots = this.NumUnitRoots;
inxInit = true(nxi, 1);

end%

