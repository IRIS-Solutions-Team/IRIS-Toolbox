% smootherForVAR  Kalman smoother for VAR-based systems
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function ...
    [X2, Px2, E, U, Y2, Py2, YInx, Y0, F, Y1, Py1] ...
    = smootherForVAR(this, A, B, K, Z, D, Omg, Sgm, y, E, x0, P0, S)

% The VAR-based state-space system is given by
%
% y = Z x + D + u,   Euu' = Sgm
% x = A(L) x(-1) + K + B e,   Eee' = Omg
%
% If AllObs==true then a full set of observations y(t) exactly
% determines x(t)

persistent REUSE

ahead = S.ahead;
tol = S.tol;
reuse = S.reuse;
allObs = S.allObs;
invFunc = S.invFunc;

%--------------------------------------------------------------------------

nx = size(A, 1);
[ny, numPeriods] = size(y);
p = size(A, 2)/nx;

if isempty(D)
    D = zeros(ny, 1);
end

ensureSymmetric = @(x) (x + x')/2;

T = [A;eye((p-1)*nx, p*nx)];

X2 = nan(nx*p, numPeriods);
Y1 = nan(ny, numPeriods);
Py1 = nan(ny, ny, numPeriods);
Px2 = zeros(nx*p, nx*p, numPeriods);
Y2 = y;
Y0 = nan(ny, numPeriods, ahead);
Py2 = nan(ny, ny, numPeriods);
F = nan(ny, ny, numPeriods);
Fi = nan(ny, ny, numPeriods);
pe = nan(ny, numPeriods);
Fipe = nan(ny, numPeriods);
L = nan(nx*p, nx*p, numPeriods);
G = nan(nx*p, ny, numPeriods);
U = [ ];

if isempty(E)
    if isempty(B)
        ne = ny;
    else
        ne = size(B, 2);
    end
    E = zeros(ne, numPeriods);
end

if isempty(B)
    Be = E;
    BOmg = Omg;
    BOmgBt = ensureSymmetric(Omg);
else
    Be = B*E;
    BOmg = B*Omg;
    BOmgBt = ensureSymmetric(BOmg*B');
end

isEmptyK = isempty(K);
isEmptyD = isempty(D);

isSgm = ~isempty(Sgm) && any(any(Sgm ~= 0));
if allObs
    PP = BOmgBt;
    FF = Z*PP*Z';
    if isSgm
        FF = FF + Sgm;
    end
    FFi = invFunc(FF);
    FF = ensureSymmetric(FF);
    FFi = ensureSymmetric(FFi);
end

% __Prediction and updating steps__

% First prediction step
nonZero = any(A ~= 0, 1);
X2(1:nx, 1) = A(:, nonZero)*x0(nonZero) + Be(:, 1);
X2(nx+1:end, 1) = x0(1:end-nx);
if ~isEmptyK
    X2(1:nx, 1) = X2(1:nx, 1) + K(:, 1);
end

if all(P0(:)==0)
    Px2(1:nx, 1:nx, 1) = BOmgBt;
else
    Px2(:, :, 1) = T*P0*T';
    Px2(1:nx, 1:nx, 1) = Px2(1:nx, 1:nx, 1) + BOmgBt;
end
Px2(:, :, 1) = ensureSymmetric(Px2(:, :, 1));

jy = false(ny, 1);
YInx = ~isnan(y);
nz2 = size(Z, 2);

for t = 1 : numPeriods
    j0 = jy;
    jy = YInx(:, t);

    % Predictions of observables
    Y0(:, t, 1) = Z*X2(1:nz2, t);
    if ~isEmptyD
        Y0(:, t, 1) = Y0(:, t, 1) + D;
    end
    if ahead>1
        hereAhead( );
    end
    % Prediction error.
    pe(jy, t) = y(jy, t) - Y0(jy, t, 1);
    if reuse && ~isempty(REUSE)
        F(:, :, t) = REUSE.F(:, :, t);
        Fi(:, :, t) = REUSE.Fi(:, :, t);
    else
        % allobserved == true indicates that all states are perfectly observed and
        % FMSE is static whenever all observations are available in this and the
        % previous period.
        if allObs && all(j0) && all(jy)
            F(:, :, t) = FF;
            Fi(:, :, t) = FFi;
        else
            F(:, :, t) = Z*Px2(1:nz2, 1:nz2, t)*Z.';
            if isSgm
                F(:, :, t) = F(:, :, t) + Sgm;
            end
            F(:, :, t) = ensureSymmetric(F(:, :, t));
            recompute = true;
            if t > 1 && all(j0 == jy)
                f = F(jy, jy, t);
                f0 = F(jy, jy, t-1);
                if  max(abs(f(:) - f0(:))) < tol
                    Fi(jy, jy, t) = Fi(jy, jy, t-1);
                    recompute = false;
                end
            end
            if recompute
                Fi(jy, jy, t) = invFunc(F(jy, jy, t));
                Fi(jy, jy, t) = ensureSymmetric(Fi(jy, jy, t));
            end
        end
    end
    Fijy = invFunc(F(jy, jy, t));
    Fipe(jy, t) = Fijy * pe(jy, t);
    G(:, jy, t) = T*Px2(:, 1:nz2, t)*Z(jy, :).' * Fijy;
    %Fipe(jy, t) = F(jy, jy, t)\pe(jy, t);
    %G(:, jy, t) = T*Px2(:, 1:nz2, t)*Z(jy, :).'/F(jy, jy, t);
    
    hereUpdate( );
    
    % L = T - G*[Z, 0].
    L(:, :, t) = T;
    L(:, 1:nz2, t) = L(:, 1:nz2, t) - G(:, jy, t)*Z(jy, :);
    if t < numPeriods
        X2(1:nx, t+1) = A(:, nonZero)*X2(nonZero, t) + Be(:, t+1);
        if ~isEmptyK
            X2(1:nx, t+1) = X2(1:nx, t+1) + K(:, min(t+1, end));
        end
        X2(nx+1:end, t+1) = X2(1:end-nx, t);
        if any(jy)
            X2(:, t+1) = X2(:, t+1) + G(:, jy, t)*pe(jy, t);
        end
        % Px = T*Px*L' + B*Omg*B';
        Px2(:, :, t+1) = T*Px2(:, :, t)*L(:, :, t)';
        if allObs && all(jy)
            % All states are perfectly observed, hence t+1 forecast MSE is
            % just PP = B*Omg*B'.
            Px2(1:nx, 1:nx, t+1) = PP;
        else
            Px2(1:nx, 1:nx, t+1) = Px2(1:nx, 1:nx, t+1) + BOmgBt;
        end
        Px2(:, :, t+1) = ensureSymmetric(Px2(:, :, t+1));
    end
end

%
% Reuse FMSE matrices for observables
%

if reuse
    if isempty(REUSE)
        REUSE = struct( );
        REUSE.F = F;
        REUSE.Fi = Fi;
    end
else
    REUSE = [ ];
end

%
% Smoothing
%

lastObs = max([0, find(any(YInx, 1), 1, 'last')]);
if lastObs<numPeriods
    Y2(:, lastObs+1:end) = Z*X2(1:nz2, lastObs+1:end);
    Py2(:, :, lastObs+1:end) = F(:, :, lastObs+1:end);
end

r = zeros(p*nx, 1);
N = 0;

% Any measurement errors?
isu = isSgm && size(Sgm, 1) == size(y, 1);
if isu
    U = zeros(ny, numPeriods);
end

for t = lastObs : -1 : 1
    jy = YInx(:, t);
    if isu
        U(:, t) = Sgm(jy, :)'*(Fipe(jy, t) - G(:, jy, t)'*r);
    end
    % r = [Z, 0]'*Fi*pe + L'*r;
    r = L(:, :, t)'*r;
    r(1:nz2) = r(1:nz2) + Z(jy, :)'*Fipe(jy, t);
    X2(:, t) = X2(:, t) + Px2(:, :, t)*r;
    E(:, t) = E(:, t) + BOmg'*r(1:nx);
    if any(~jy)
        Y2(~jy, t) = Z(~jy, :)*X2(1:nz2, t);
        if isu
            Y2(~jy, t) = Y2(~jy, t) + U(~jy, t);
        end
    end
    % N = [Z, 0]'*Fi*[Z, 0] + L'*N*L;
    N = L(:, :, t)'*N*L(:, :, t);
    N(1:nz2, 1:nz2) = N(1:nz2, 1:nz2) + Z(jy, :).'*Fi(jy, jy, t)*Z(jy, :);
    PxNPx = Px2(:, :, t)*N*Px2(:, :, t);
    Px2(:, :, t) = ensureSymmetric(Px2(:, :, t) - PxNPx);
    Py2(:, :, t) = ensureSymmetric(F(:, :, t) - Z*PxNPx(1:nz2, 1:nz2)*Z');
    Py2(jy, :, t) = 0;
    Py2(:, jy, t) = 0;
    if allObs && all(jy)
        Px2(1:nx, 1:nx, t) = 0;
    end
end

return

    function hereUpdate( )
        X1 = X2(:, t) + Px2(:, 1:nz2, t)*Z(jy, :).'*Fipe(jy, t);
        Y1(:, t) = Z*X1(1:nz2, :);
        if ~isEmptyD
            Y1(:, t) = Y1(:, t) + D;
        end
    end%


    function hereAhead( )
        x = nan(size(X2, 1), ahead);
        x(:, 1) = X2(:, t);
        for kk = 2 : min(ahead, numPeriods-t+1)
            x(1:nx, kk) = A(:, nonZero)*x(nonZero, kk-1);
            if ~isEmptyK
                x(1:nx, kk) = x(1:nx, kk) + K(:, min(kk, end));
            end
            x(nx+1:end, kk) = x(1:end-nx, kk-1);
            y0 = Z*x(1:nz2, kk);
            if ~isEmptyD
                y0 = y0 + D;
            end
            Y0(:, t+kk-1, kk) = y0;
        end
    end%
end%

