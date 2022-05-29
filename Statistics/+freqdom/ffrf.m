function f = ffrf(T, R, ~, Z, H, ~, U, Omega, freq, tolerance, maxiter)
% ffrf  Frequence response function for general state space
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = size(Z, 1);
[nx, nb] = size(T);
nf = nx - nb;
% ne = size(R, 2);

T = [zeros([nx, nf]), T];
Z = [zeros([ny, nf]), Z];
Sigmaa = R*Omega*transpose(R);
Sigmay = H*Omega*transpose(H);

%Sigmay = eye(ny)*0.5;

% Steady-state Kalman filter.
Pp = eye(size(T));
Pf = Pp;
%Pp0 = inf(size(T));
%Pf0 = Pp0;
maxdiff = Inf;
count = 0;
while maxdiff>tolerance && count<maxiter
    Pp0 = Pp;
    Pf0 = Pf;
    %  Pf = Pp - Pp(:, nf+1:end)*transpose(Z(:, nf+1:end))*inv(Z(:, nf+1:end)*Pp(nf+1:end, nf+1:end)*transpose(Z(:, nf+1:end))+Sigmay)*Z(:, nf+1:end)*Pp(nf+1:end, :);
    Q = ginverse(Z(:, nf+1:end)*Pp(nf+1:end, nf+1:end)*transpose(Z(:, nf+1:end))+Sigmay);
    Pf = Pp - Pp(:, nf+1:end)*transpose(Z(:, nf+1:end))*(Q*Z(:, nf+1:end))*Pp(nf+1:end, :);
    Pp = T(:, nf+1:end)*Pf(nf+1:end, nf+1:end)*transpose(T(:, nf+1:end)) + Sigmaa;
    %  Pf = Pp - Pp*transpose(Z)*((Z*Pp*transpose(Z)+Sigmay)\Z*Pp);
    %  Pp = T*Pf*transpose(T) + Sigmaa;
    maxdiff = max(abs([Pp(:);Pf(:)]-[Pp0(:);Pf0(:)]));
    count = count + 1;
end

if maxdiff>tolerance
    utils.warning('freqdom', ...
        'Convergence not reached for steady-state Kalman filter.');
end

if rank(Pp)<size(Pp, 1)
    J = Pf*transpose(T)*pinv(Pp);
else
    J = Pf*transpose(T)/Pp;
end
tmp = Z*Pp*transpose(Z)+Sigmay;
if rank(tmp)<size(Sigmay, 1)
    C = Pp*transpose(Z)*pinv(tmp);
else
    C = Pp*transpose(Z)/tmp;
end
K = T*C;
%k = K(nf+1:end, :);

I = eye(size(T));

f = zeros(nx, ny, length(freq));
z = exp(-1i*freq);
zinv = exp(1i*freq);
for k = 1 : length(freq)
    B = ginverse(I - (T - K*Z)*z(k));
    A = B * K;
    f(:, :, k) = (I-J*zinv(k)) \ ((I-C*Z)*A*z(k) + C - J*A);
    if ~isempty(U)
        f(nf+1:end, :, k) = U*f(nf+1:end, :, k);
    end
end

end%


function [A, R] = ginverse(A)
    if isempty(A)
        A = zeros(size(A), class(A));
        return
    end
    % Determine the rank of `A`.
    m = size(A, 1);
    s = svd(A);
    tol = m * eps(max(s));
    R = sum(s>tol);
    % Calculate inverse or pseudo-inverse depending on the rank.
    if R==m
        A = inv(A);
    elseif R==0
        A = zeros(size(A), class(A));
    else
        [u, ~, v] = svd(A, 0);
        s = diag(1./s(1:R));
        A = v(:, 1:R)*s*transpose(u(:, 1:R));
    end
end%

