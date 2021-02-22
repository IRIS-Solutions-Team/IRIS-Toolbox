function y2 = smoother(init, yc, A, C, E, Omega, Sigma)

ny = size(A, 1);
p = size(A, 2)/ny;
na = ny*p;
T = [A; eye((p-1)*ny, p*ny)];

numPeriods = size(yc, 2);

indexObs = ~isnan(yc);
isObs = any(indexObs(:));

a1 = init;
P1 = zeros(na);
Z0 = eye(ny, na);
store = struct( );
store.ZtFiNu = cell(1, numPeriods);
store.L = cell(1, numPeriods);
a0 = nan(na, numPeriods); 
for t = 1 : numPeriods
    a0(:, t) = T*a1;
    a0(1:ny, t) = a0(1:ny, t) + C + E(:, t);
    if ~isObs
        a1 = a0(:, t);
        continue
    end
    P0 = T*P1*T';
    P0(1:ny, 1:ny) = P0(1:ny, 1:ny) + Omega;
    P0 = (P0 + P0')/2;
    ix = indexObs(:, t);
    if any(ix)
        Z = Z0(ix, :);
        y0 = Z*a0(:, t);
        F = Z*P0*Z' + Sigma(ix, ix);
        F = (F + F')/2;
        nu = yc(ix, t) - y0;
        FiZ = F\Z;
        ZtFi = FiZ';
        ZtFiNu = ZtFi*nu;
        a1 = a0(:, t) + P0*ZtFiNu;
        P1 = P0 - P0*ZtFi*Z*P0;
        P1 = (P1 + P1')/2;
        K = T*P0*ZtFi;
        L = T - K*Z;
    else
        a1 = a0(:, t);
        P1 = P0;
        ZtFiNu = zeros(na, 1);
        K = zeros(na, 0);
        L = T;
    end
    store.P0{t} = P0;
    store.ZtFiNu{t} = ZtFiNu;
    store.L{t} = L;
end

if ~isObs
    y2 = a0(1:ny, :);
    return
end

y2 = nan(ny, numPeriods);
r = zeros(na, 1);
for t = numPeriods : -1 : 1
    r = store.ZtFiNu{t} + transpose(store.L{t})*r;
    y2(:, t) = a0(1:ny, t) + store.P0{t}(1:ny, :)*r;
end

end

