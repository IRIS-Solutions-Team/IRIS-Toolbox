%{
% 
% # `solutionMatrices` ^^(Model)^^
% 
% {== Access first-order state-space (solution) matrices ==}
% 
% 
% ## Syntax
% 
%     output = solutionMatrices(model, ...)
% 
% 
% ## Input Arguments
% 
% __`model`__ [ Model ]
% > 
% > Solved model object.
% > 
% 
% 
% 
% ## Output Arguments
% 
% __`T`__ [ numeric ]
% > 
% > Transition matrix.
% > 
% 
% 
% __`R`__ [ numeric ]
% > 
% > Matrix at the shock vector in transition equations.
% > 
% 
% 
% __`K`__ [ numeric ]
% > 
% > Constant vector in transition equations.
% > 
% 
% 
% __`Z`__ [ numeric ]
% > 
% > Matrix mapping transition variables to measurement
% > 
% 
% variables.
% 
% __`H`__ [ numeric ]
% > 
% > Matrix at the shock vector in measurement
% > 
% 
% equations.
% 
% __`D`__ [ numeric ]
% > 
% > Constant vector in measurement equations.
% > 
% 
% 
% __`U`__ [ numeric ]
% > 
% > Transformation matrix for predetermined variables.
% > 
% 
% 
% __`Omg`__ [ numeric ]
% > 
% > Covariance matrix of shocks.
% > 
% 
% 
% 
% ## Options
% 
% __`Triangular=true`__ [ `true` | `false` ] -
% If true, the state-space form returned has the transition matrix `T`
% quasi triangular and the vector of predetermined variables transformed
% accordingly; this is the default form used in IRIS calculations. If
% false, the state-space system is based on the original vector of
% transition variables.
% 
% 
% ## Description
% 
% The state-space representation has the following form:
% 
%     [xf;alpha] = T*alpha(-1) + K + R*e
% 
%     y = Z*alpha + D + H*e
% 
%     xb = U*alpha
% 
%     Cov[e] = Omg
% 
% where `xb` is an nb-by-1 vector of predetermined (backward-looking)
% transition variables and their auxiliary lags, `xf` is an nf-by-1 vector
% of non-predetermined (forward-looking) variables and their auxiliary
% leads, `alpha` is a transformation of `xb`, `e` is an ne-by-1 vector of
% shocks, and `y` is an ny-by-1 vector of measurement variables.
% Furthermore, we denote the total number of transition variables, and
% their auxiliary lags and leads, nx = nb + nf.
% 
% The transition matrix, `T`, is, in general, rectangular nx-by-nb.
% Furthremore, the transformed state vector alpha is chosen so that the
% lower nb-by-nb part of `T` is quasi upper triangular.
% 
% You can use the `get(m, 'xiVector')` function to learn about the order of
% appearance of transition variables and their auxiliary lags and leads in
% the vectors `xb` and `xf`. The first nf names are the vector `xf`, the
% remaining nb names are the vector `xb`.
% 
% 
% ## Example
% 
% 
% 
%}
% --8<--


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

logPrefix = model.Quantity.LOG_PREFIX;
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

