function [f,count] = ffrf2(T,R,~,Z,H,~,U,Omg,freq,tolerance,maxiter)
% ffrf  [Not a public function] Frequence response function for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if isempty(tolerance)
    tolerance = 1e-7;
end

if isempty(maxiter)
    maxiter = 500;
end

%**************************************************************************

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;

Tf = T(1:nf,:);
Rf = R(1:nf,:);
T = T(nf+1:end,:);
R = R(nf+1:end,:);
Sy = H*Omg*H';
ROmg = R*Omg;
Sa = ROmg*R';

% Compute steady-state Kalman filter. Because the covariance matrix for the
% measurement shocks can be singular (or absent at all) we cannot, in
% general, use the doubling algorithm, and must iterate on the Riccati
% equation.
P = Sa;
count = 0;
d = Inf;
K = Inf;
L = Inf;
Zt = Z';
while d > tolerance && count <= maxiter
    K0 = K;
    PZt = P*Zt;
    F = Z*PZt + Sy;
    K = T*(PZt/F);
    L = T - K*Z;
    P = T*P*L' + Sa;
    P = (P+P')/2;
    d = max(abs(K(:)-K0(:)));
    count = count + 1;
end

% Find infinite double-sided polynomial filters
%     a(t) = Fa(q) y(t),
%     xf(t) = Ff(q) y(t),
% where q is the lag operator, and evaluate them for each frequency.
nfreq = length(freq);
ZtFi = Z'/F;
T_KZ = T-K*Z;
RfROmgt = Rf*ROmg';
f = zeros(nx,ny,nfreq);
Ib = eye(nb);
Iy = eye(ny);
Lt = L';
Ff = zeros(nf,ny);
for k = 1 : nfreq
    q = exp(-1i*freq(k));
    qi = 1/q;
    J = (Ib - T_KZ*q) \ (K*q);
    A = (Ib - Lt*qi) \ (ZtFi * (Iy - Z*J));
    % FRF(q) for alpha vector.
    Fa = J + P*A;
    if nf > 0
        % FRF(q) for forward-looking variables.
        Ff = Tf*Fa*q + RfROmgt*A;
    end
    if ~isempty(U)
        % Transform alpha vector to x vector.
        f(:,:,k) = [Ff;U*Fa];
    else
        f(:,:,k) = [Ff;Fa];
    end
end

end
