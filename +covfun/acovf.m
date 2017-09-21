function [C,Diffuse] = acovf(T,R,~,Z,H,~,U,Omg,Eig,Order)
% acovf  [Not a public function] Autocovariance function for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

realSmall = getrealsmall( );

if isempty(Eig)
    Eig = ordeig(T);
end

nY = size(Z,1);
[nX,nB] = size(T);
nF = nX - nB;
nE = size(R,2);

if nY == 0
    Z = zeros(0,nB);
    H = zeros(0,nE);
end

Tf = T(1:nF,:);
Ta = T(nF+1:end,:);
Rf = R(1:nF,:);
Ra = R(nF+1:end,:);

% Detect unit root elements of y, xf, alpha, and xb.
unitroots = abs(abs(Eig(1:nB)) - 1) <= realSmall;
dY = any(abs(Z(:,unitroots)) > realSmall,2).';
dF = any(abs(Tf(:,unitroots)) > realSmall,2).';
dA = unitroots;
if ~isempty(U)
    dB = any(abs(U(:,unitroots)) > realSmall,2).';
else
    dB = dA;
end
Caa = zeros(nB);

% Solve Lyapunov equation for the contemporaneous covariance matrix of the
% stable elements of the vector alpha.
Caa(~dA,~dA) = covfun.lyapunov(Ta(~dA,~dA),Ra(~dA,:)*Omg*Ra(~dA,:).');

Ra_Omg_Rft = Ra*Omg*Rf.';
Cff = Tf*Caa*Tf.' + Rf*Omg*Rf.';
Cyy = Z*Caa*Z.' + H*Omg*H.';
Cyf = Z*Ta*Caa*Tf.' + Z*Ra_Omg_Rft;
Cya = Z*Caa;
Cfa = Tf*Caa*Ta.' + Ra_Omg_Rft.';

C = zeros(nY+nF+nB,nY+nF+nB,1+Order);
C(:,:,1) = [ ...
    Cyy,Cyf,Cya; ...
    Cyf',Cff,Cfa; ...
    Cya',Cfa',Caa; ...
    ];
C(:,:,1) = (C(:,:,1) + C(:,:,1)')/2;
Diffuse = [dY,dF,dB];

if Order > 0
    TT = [Z*Ta;Tf;Ta];
    for i = 1 : Order
        C(1:end,:,i+1) = TT*C(nY+nF+1:end,:,i);
    end
end

if ~isempty(U)
    for i = 0 : Order
        C(nY+nF+1:end,:,i+1) = U*C(nY+nF+1:end,:,i+1);
        C(:,nY+nF+1:end,i+1) = C(:,nY+nF+1:end,i+1)*U.';
    end
end

C(Diffuse,:,:) = Inf;
C(:,Diffuse,:) = Inf;

end
