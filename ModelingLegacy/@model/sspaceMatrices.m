function [T, R, K, Z, H, D, U, Omega, Zb, Y, inxTE, inxME] = ...
        sspaceMatrices(this, variantsRequested, keepExpansion, keepTriangular)
% sspaceMatrices  Return state space matrices for given parameter variant
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

if nargin<3
    keepExpansion = true;
end

if nargin<4
    keepTriangular = true;
end

%--------------------------------------------------------------------------

if strcmp(variantsRequested, ':')
    variantsRequested = 1 : length(this.Variant);
end

returnOmega = nargout>7;
returnY = nargout>9;

[T, R, K, Z, H, D, U, Y, Zb] = getIthFirstOrderSolution(this.Variant, variantsRequested);

[~, nxi, nb, nf, ne] = sizeOfSolution(this.Vector);
numVariantsRequested = numel(variantsRequested);
numHashEquations = nnz(this.Equation.IxHash);

if ~keepExpansion
    R = R(:, 1:ne);
    if returnY
        Y = Y(:, 1:numHashEquations);
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

if ~keepTriangular
    % T <- U*T/U;
    % R <- U*R;
    % K <- U*K;
    % Z <- Zb;
    % U <- eye
    % Y <- U*Y
    for i = 1 : numVariantsRequested
        ithU = U(:, :, i);
        T(:, :, i) = T(:, :, i) / ithU;
        T(nf+1:end, :, i) = ithU*T(nf+1:end, :, i);
        R(nf+1:end, :, i) = ithU*R(nf+1:end, :, i);
        K(nf+1:end, :, i) = ithU*K(nf+1:end, :, i);
        Z(:, :, i) = Zb(:, :, i);
        if returnY
            Y(nf+1:end, :, i) = ithU*Y(nf+1:end, :, i);
        end
    end
    U = repmat(eye(nb), 1, 1, numVariantsRequested);
end

if returnOmega
    Omega = getIthOmega(this, variantsRequested);
end

% Make sure measurement errors have zeros in transition equations and vice
% versa
if nargout>=11
    inxE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
    inxTE = this.Quantity.Type(inxE)==TYPE(31);
    inxME = this.Quantity.Type(inxE)==TYPE(32);
end

end%

