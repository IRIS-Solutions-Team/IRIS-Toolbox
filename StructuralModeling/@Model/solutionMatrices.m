% solutionMatrices  Access first-order state-space (solution) matrices
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

% >=R2019b
%{
function output = solutionMatrices(this, opt)

arguments
    this Model

    opt.Triangular (1, 1) logical = true
    opt.RemoveInactiveShocks (1, 1) logical = false
    opt.KeepExpansion (1, 1) logical = true
    opt.MatrixFormat (1, 1) string = "NamedMat"
end
%}
% >=R2019b


% <=R2019a
%(
function output = solutionMatrices(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Triangular", true);
    addParameter(ip, "RemoveInactiveShocks", false);
    addParameter(ip, "KeepExpansion", true);
    addParameter(ip, "MatrixFormat", "NamedMat");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


[T, R, K, Z, H, D, U, Omg, ~] ...
    = getSolutionMatrices(this, ':', opt.KeepExpansion, opt.Triangular);

[~, numXi, numXib, numXif, numE] = sizeSolution(this.Vector);

inxShocksToKeep = true(1, numE);
if opt.RemoveInactiveShocks
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

if ~opt.Triangular
    alphaVector0 = string(printSolutionVector(this, this.Vector.Solution{2}(numXif+1:end), logPrefix));
    alphaVector1 = string(printSolutionVector(this, this.Vector.Solution{2}(numXif+1:end)-1i, logPrefix));
else
    alphaVector0 = "alpha" + string(1:numXib);
    alphaVector1 = alphaVector0 + "{-1}";
    xiVector(numXif+1:end) = alphaVector0;
end

if startsWith(string(opt.MatrixFormat), "named", "ignoreCase", true)
    eVectorX = eVector;
    forward = size(R, 2) / numE - 1;
    if forward>1
        eVectorX = local_expandShockNames(eVectorX, forward);
    end
    T = namedmat(T, xiVector, alphaVector1);
    R = namedmat(R, xiVector, eVectorX);
    K = namedmat(K, xiVector, this.INTERCEPT_STRING);
    Z = namedmat(Z, yVector, alphaVector0);
    H = namedmat(H, yVector, eVector);
    D = namedmat(D, yVector, this.INTERCEPT_STRING);
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

%
% Local functions
%

function eVector = local_expandShockNames(eVector, horizon)
    %(
    temp = eVector;
    for i = 1 : horizon
        time = "{+" + string(i) + "}";
        eVector = [eVector, temp + time];
    end
    %)
end%

