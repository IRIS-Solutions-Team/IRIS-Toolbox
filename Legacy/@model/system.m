
% >=R2019b
%{
function [A, B, C, D, F, G, H, J, list, numF, deriv] = system(this, opt)


arguments
    this

    opt.Eqtn = @all
        opt.Equations__Eqtn = []
    opt.ForceDiff (1, 1) logical = false
    opt.Normalize (1, 1) logical = true
    opt.MatrixFormat (1, 1) string = "NamedMatrix"
    opt.Sparse (1, 1) logical = false
    opt.Symbolic (1, 1) logical = true

    opt.Select (1, 1) logical = true 
end
%}
% >=R2019b


% <=R2019a
%(
function [A, B, C, D, F, G, H, J, list, numF, deriv] = system(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Eqtn", @all);
        addParameter(ip, "Equations__Eqtn", []);
    addParameter(ip, "ForceDiff", false);
    addParameter(ip, "Normalize", true);
    addParameter(ip, "MatrixFormat", "NamedMatrix");
    addParameter(ip, "Sparse", false);
    addParameter(ip, "Symbolic", true);
    addParameter(ip, "Select", true );
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], false);


if ~opt.Select && ~opt.ForceDiff
    opt.ForceDiff = true;
end


CONSTANT_COLUMN = "Constant";

numVariants = countVariants(this);
numM = nnz(this.Equation.Type==1);
numT = nnz(this.Equation.Type==2);

if opt.Sparse && numVariants>1
    utils.warning('model:system', ...
        ['Cannot return system matrices as sparse matrices in models ', ...
        'with multiple parameterizations. Returning full matrices instead.']);
    opt.Sparse = false;
end

% System matrices.
if opt.Sparse && numVariants==1
    [syst, ~, deriv] = systemFirstOrder(this, 1, opt);
    F = syst.A{1}; %#ok<*AGROW>
    G = syst.B{1};
    H = syst.K{1};
    J = syst.E{1};
    A = syst.A{2};
    B = syst.B{2};
    C = syst.K{2};
    D = syst.E{2};
else
    for v = 1 : numVariants
        [syst, ~, deriv] = systemFirstOrder(this, v, opt);
        F(:, :, v) = full(syst.A{1}); %#ok<*AGROW>
        G(:, :, v) = full(syst.B{1});
        H(:, 1, v) = full(syst.K{1});
        J(:, :, v) = full(syst.E{1});
        A(:, :, v) = full(syst.A{2});
        B(:, :, v) = full(syst.B{2});
        C(:, 1, v) = full(syst.K{2});
        D(:, :, v) = full(syst.E{2});
    end
end

logPrefix = model.Quantity.LOG_PREFIX;
yVector = string(printSolutionVector(this, "y", logPrefix));
xVector0 = string(printSolutionVector(this, this.Vector.System{2}, logPrefix));
xVector1 = string(printSolutionVector(this, this.Vector.System{2}+1i, logPrefix));
eVector = string(printSolutionVector(this, "e", logPrefix));
mEquations = string(model.Equation.extractInput(this.Equation.Input(1:numM), "dynamic"));
tEquations = string(model.Equation.extractInput(this.Equation.Input(numM+(1:numT)), "dynamic"));
list = {yVector, xVector1, eVector, mEquations, tEquations};

% Number of forward-looking variables.
numF = sum( imag(this.Vector.System{2})>=0 );

if startsWith(string(opt.MatrixFormat), "named", "ignoreCase", true)
    A = namedmat(A, tEquations, xVector1);
    B = namedmat(B, tEquations, xVector0);
    C = namedmat(C, tEquations, CONSTANT_COLUMN);
    D = namedmat(D, tEquations, eVector);
    F = namedmat(F, mEquations, yVector);
    G = namedmat(G, mEquations, xVector1(numF+1:end));
    H = namedmat(H, mEquations, CONSTANT_COLUMN);
    J = namedmat(J, mEquations, eVector);
end

end%

