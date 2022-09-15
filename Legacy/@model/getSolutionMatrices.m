
function ...
    [T, R, K, Z, H, D, U, Omega, Zb, Y, inxV, inxW, numUnitRoots, inxInit] ...
    = getSolutionMatrices(this, variantsRequested, keepExpansion, keepTriangular)

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

[ny, ~, nb, nf, ne, ~, nz] = sizeSolution(this);
numVariantsRequested = numel(variantsRequested);
numHashEquations = nnz(this.Equation.IxHash);

[T, R, K, Z, H, D, U, Y, Zb, T0] ...
    = getIthFirstOrderSolution(this.Variant, variantsRequested);

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
    if nz>0
        Zb = zeros(nz, nb, numVariantsRequested);
    else
        Zb = zeros(ny, nb, numVariantsRequested);
    end
end

if isempty(H)
    H = zeros(ny, ne, numVariantsRequested);
end

if isempty(D)
    D = zeros(ny, 1, numVariantsRequested);
end

if ~keepTriangular
    % T <- U*T/U; if untransformed transition matrix is not available 
    % R <- U*R;
    % K <- U*K;
    % Z <- Zb;
    % U <- eye
    % Y <- U*Y

    % Backward compatibility
    if ~isempty(T0)
        T = T0;
    else
        for v = 1 : numVariantsRequested
            U__ = U(:, :, v);
            T(:, :, v) = T(:, :, v) / U__;
            T(nf+1:end, :, v) = U__*T(nf+1:end, :, v);
        end
    end

    for v = 1 : numVariantsRequested
        U__ = U(:, :, v);
        R(nf+1:end, :, v) = U__*R(nf+1:end, :, v);
        K(nf+1:end, :, v) = U__*K(nf+1:end, :, v);
        if returnY
            Y(nf+1:end, :, v) = U__*Y(nf+1:end, :, v);
        end
    end

    if nz==0
        Z = Zb;
    end
    U = [];
end

if returnOmega
    Omega = getIthOmega(this, variantsRequested);
end

% Make sure measurement errors have zeros in transition equations and vice
% versa
if returnInx
    inxE = getIndexByType(this.Quantity, 31, 32);
    inxW = this.Quantity.Type(inxE)==31;
    inxV = this.Quantity.Type(inxE)==32;
end

if returnUnitRoots
    numUnitRoots = getNumOfUnitRoots(this.Variant, variantsRequested);
end

if returnInit
    inxInit = this.Variant.InxInit(:, :, variantsRequested);
end

end%

