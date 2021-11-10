% solutionMatrices  Access first-order state-space (solution) matrices
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 IRIS Solutions Team

function output = solutionMatrices(this, options)

arguments
    this Model

    options.Triangular (1, 1) logical = true
    options.RemoveInactiveShocks (1, 1) logical = false
    options.KeepExpansion (1, 1) logical = true
    options.MatrixFormat (1, 1) string = "NamedMat"
end

[T, R, K, Z, H, D, U, Omg, ~] ...
    = sspaceMatrices(this, ':', options.KeepExpansion, options.Triangular);

[~, numXi, numXib, numXif, numE] = sizeSolution(this.Vector);

inxShocksToKeep = true(1, numE);
if options.RemoveInactiveShocks
    inxShocksToKeep = ~diag( all(Omg==0, 3) );
    R = reshape(R, [numXi, numE, size(R, 2)/numE]);
    R = R(:, inxShocksToKeep, :);
    R = R(:, :);
    H = H(:, inxShocksToKeep);
    Omg = Omg(inxShocksToKeep, inxShocksToKeep);
end

logPrefix = model.component.Quantity.LOG_PREFIX;
yVector = string(printSolutionVector(this, "y", logPrefix));
xiVector = string(printSolutionVector(this, this.Vector.Solution{2}, logPrefix));
xifVector = xiVector(1:numXif);
xibVector = xiVector(numXif+1:end);
eVector = string(printSolutionVector(this, "e", logPrefix));
eVector = eVector(inxShocksToKeep);

if ~options.Triangular
    alphaVector0 = string(printSolutionVector(this, this.Vector.Solution{2}(numXif+1:end), logPrefix));
    alphaVector1 = string(printSolutionVector(this, this.Vector.Solution{2}(numXif+1:end)-1i, logPrefix));
else
    alphaVector0 = "alpha" + string(1:numXib);
    alphaVector1 = alphaVector0 + "{-1}";
    xiVector(numXif+1:end) = alphaVector0;
end

if startsWith(string(options.MatrixFormat), "named", "ignoreCase", true)
    T = namedmat(T, xiVector, alphaVector1);
    R = namedmat(R, xiVector, eVector);
    K = namedmat(K, xiVector, "1");
    Z = namedmat(Z, yVector, alphaVector0);
    H = namedmat(H, yVector, eVector);
    D = namedmat(D, yVector, "1");
    if ~isempty(U)
        U = namedmat(U, xibVector, alphaVector0);
    end
    Omg = namedmat(Omg, eVector, eVector);
end

output = struct();

output.T = T;
output.R = R;
output.k = K;
output.Z = Z;
output.H = H;
output.d = D;
output.U = U;
output.Omega = Omg;

output.YVector = yVector;
output.XVector = [xifVector, xibVector];
output.EVector = eVector;

end%

