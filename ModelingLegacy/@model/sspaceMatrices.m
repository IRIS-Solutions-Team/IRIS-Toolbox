function [T, R, K, Z, H, D, U, Omega, Zb, Y, inxV, inxW, numUnitRoots, inxInit] = ...
        sspaceMatrices(this, variantsRequested, keepExpansion, keepTriangular)
% sspaceMatrices  Return state space matrices for given parameter variant
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

if nargin<3
    requiredForward = 0;
    keepExpansion = true;
else
    if islogical(keepExpansion)
        requiredForward = 0;
    else
        requiredForward = keepExpansion;
        keepExpansion = true;
    end
end

if nargin<4
    keepTriangular = true;
end

%--------------------------------------------------------------------------

returnOmega     = nargout>= 8;
returnY         = nargout>=10;
returnInx       = nargout>=11;
returnUnitRoots = nargout>=13;
returnInit      = nargout>=14;

if strcmp(variantsRequested, ':')
    variantsRequested = 1 : numel(this.Variant);
end

[ny, nxi, nb, nf, ne] = sizeOfSolution(this.Vector);
numVariantsRequested = numel(variantsRequested);
numHashEquations = nnz(this.Equation.IxHash);

[T, R, K, Z, H, D, U, Y, Zb] = getIthFirstOrderSolution(this.Variant, variantsRequested);

currentForward = size(R, 2)/ne - 1;
if requiredForward>currentForward
    expansion = getIthFirstOrderExpansion(this.Variant, variantsRequested);
    R = model.expandFirstOrder(R, [ ], expansion, requiredForward);
end

if isequal(keepExpansion, false)
    R = R(:, 1:ne, :);
    if returnY
        Y = Y(:, 1:numHashEquations, :);
    end
end

if isempty(Z)    
    Z = zeros(ny, nb, numVariantsRequested);
end

if isempty(Zb)
    Zb = zeros(ny, nb, numVariantsRequested);
end

if isempty(H)
    H = zeros(ny, ne, numVariantsRequested);
end

if isempty(D)
    D = zeros(ny, 1, numVariantsRequested);
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
if returnInx
    inxE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
    inxW = this.Quantity.Type(inxE)==TYPE(31);
    inxV = this.Quantity.Type(inxE)==TYPE(32);
end

if returnUnitRoots
    numUnitRoots = getNumOfUnitRoots(this.Variant, variantsRequested);
end

if returnInit
    inxInit = this.Variant.InxInit(:, :, variantsRequested);
end

end%

