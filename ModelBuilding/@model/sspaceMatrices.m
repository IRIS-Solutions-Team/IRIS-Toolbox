function [T, R, K, Z, H, D, U, Omega, Zb, Y] = ...
        sspaceMatrices(this, variantsRequested, keepExpansion, triangular)
% sspaceMatrices  Return state space matrices for given parameter variant.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if nargin<3
    keepExpansion = true;
end

if nargin<4
    triangular = true;
end

%--------------------------------------------------------------------------

returnOmega = nargout>7;
returnY = nargout>9;

[T, R, K, Z, H, D, U, Y, Zb] = getIthFirstOrderSolution(this.Variant, variantsRequested);
[~, nxi, nb, nf, ne] = sizeOfSolution(this.Vector);
numVariantsRequested = numel(variantsRequested);
nn = nnz(this.Equation.IxHash);

if ~keepExpansion
    R = R(:, 1:ne);
    if returnY
        Y = Y(:, 1:nn);
    end
end

if isempty(Z)    
    Z = zeros(0, nb, numVariantsRequested);
end

if isempty(Zb)
    Zb = zeros(0, nb, numVariantsRequested);
end

if isempty(H)
    H = zeros(0, ne, numVariantsRequested);
end

if isempty(D)
    D = zeros(0, 1, numVariantsRequested);
end

if ~triangular
    % T <- U*T/U;
    % R <- U*R;
    % K <- U*K;
    % Z <- Zb;
    % U <- eye
    % Y <- U*Y
    for v = 1 : numVariantsRequested
        vthU = U(:, :, v);
        T(:, :, v) = T(:, :, v) / vthU;
        T(nf+1:end, :, v) = vthU*T(nf+1:end, :, v);
        R(nf+1:end, :, v) = vthU*R(nf+1:end, :, v);
        K(nf+1:end, :, v) = vthU*K(nf+1:end, :, v);
        Z(:, :, v) = Zb(:, :, v);
        if returnY
            Y(nf+1:end, :, v) = vthU*Y(nf+1:end, :, v);
        end
    end
    U = repmat(eye(nb), 1, 1, numVariantsRequested);
end

if returnOmega
    Omega = getIthOmega(this, variantsRequested);
end

end
