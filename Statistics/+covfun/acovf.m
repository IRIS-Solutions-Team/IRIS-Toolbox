function [C, indexDiffuse] = acovf(T, R, ~, Z, H, ~, U, Omg, indexUnitRoots, maxOrder)
% acovf  Autocovariance function for general state space
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

realSmall = getrealsmall( );

[nxi, nb] = size(T);
nf = nxi - nb;
ne = size(R, 2);

if ~isvector(indexUnitRoots) || length(indexUnitRoots)~=nb
    throw( ...
        exception.Base('CovFun:IndexUnitRootsSize', 'error') ...
    );
end

if isempty(Z)
    ny = 0;
    Z = zeros(0, nb);
    H = zeros(0, ne);
else
    ny = size(Z, 1);
end

Tf = T(1:nf, :);
Ta = T(nf+1:end, :);
Rf = R(1:nf, :);
Ra = R(nf+1:end, :);

% Detect unit root elements of y, xf, alpha, and xb.
% indexUnitRoots = abs(abs(eigenValues(1:nb)) - 1)<=realSmall;
indexDiffuseY = any(abs(Z(:, indexUnitRoots))>realSmall, 2).';
indexDiffuseF = any(abs(Tf(:, indexUnitRoots))>realSmall, 2).';
indexDiffuseA = indexUnitRoots;
if ~isempty(U)
    indexDiffuseB = any(abs(U(:, indexUnitRoots))>realSmall, 2).';
else
    indexDiffuseB = indexDiffuseA;
end
Caa = zeros(nb);

% Solve Lyapunov equation for the contemporaneous covariance matrix of the
% stable elements of the vector alpha.
Caa(~indexDiffuseA, ~indexDiffuseA) = covfun.lyapunov( ...
    Ta(~indexDiffuseA, ~indexDiffuseA), Ra(~indexDiffuseA, :)*Omg*Ra(~indexDiffuseA, :).' ...
);

Ra_Omg_Rft = Ra*Omg*Rf.';
Cff = Tf*Caa*Tf.' + Rf*Omg*Rf.';
Cyy = Z*Caa*Z.' + H*Omg*H.';
Cyf = Z*Ta*Caa*Tf.' + Z*Ra_Omg_Rft;
Cya = Z*Caa;
Cfa = Tf*Caa*Ta.' + Ra_Omg_Rft.';

C = zeros(ny+nf+nb, ny+nf+nb, 1+maxOrder);
C(:, :, 1) = [ ...
    Cyy, Cyf, Cya; ...
    Cyf', Cff, Cfa; ...
    Cya', Cfa', Caa; ...
    ];
C(:, :, 1) = (C(:, :, 1) + C(:, :, 1)')/2;
indexDiffuse = [indexDiffuseY, indexDiffuseF, indexDiffuseB];

if maxOrder>0
    TT = [Z*Ta;Tf;Ta];
    for i = 1 : maxOrder
        C(1:end, :, i+1) = TT*C(ny+nf+1:end, :, i);
    end
end

if ~isempty(U)
    for i = 0 : maxOrder
        C(ny+nf+1:end, :, i+1) = U*C(ny+nf+1:end, :, i+1);
        C(:, ny+nf+1:end, i+1) = C(:, ny+nf+1:end, i+1)*U.';
    end
end

C(indexDiffuse, :, :) = Inf;
C(:, indexDiffuse, :) = Inf;

end
