% >=R2019b
%{
function [A, B, C, D, F, G, H, J, list, numF, deriv] = system(this, options, legacy)

arguments
    this

    options.Eqtn = @all
    options.ForceDiff (1, 1) logical = false
    options.Normalize (1, 1) logical = true
    options.MatrixFormat (1, 1) string = "NamedMatrix"
    options.Sparse (1, 1) logical = false
    options.Symbolic (1, 1) logical = true

    legacy.Select (1, 1) logical = true 
end

if ~legacy.Select && ~options.ForceDiff
    options.ForceDiff = true;
end
%}
% >=R2019b

% <=R2019a
%(
function [A, B, C, D, F, G, H, J, list, numF, deriv] = system(this, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.system');
    pp.addRequired('Model', @(x) isa(x, 'model'));
    pp.addParameter({'Eqtn', 'Equations'}, @all, @(x) isequal(x, @all) || ischar(x));
    pp.addParameter({'Normalize', 'Normalise'}, true, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Select', true, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('ForceDiff', false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('MatrixFormat', 'NamedMatrix');
    pp.addParameter('Sparse', false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Symbolic', true, @(x) isequal(x, true) || isequal(x, false));
end
pp.parse(this, varargin{:});
options = pp.Options;

if ~options.Select && ~options.ForceDiff
    options.ForceDiff = true;
end
%)
% <=R2019a

CONSTANT_COLUMN = "Constant";

numVariants = countVariants(this);
numM = nnz(this.Equation.Type==1);
numT = nnz(this.Equation.Type==2);

if options.Sparse && numVariants>1
    utils.warning('model:system', ...
        ['Cannot return system matrices as sparse matrices in models ', ...
        'with multiple parameterizations. Returning full matrices instead.']);
    options.Sparse = false;
end

% System matrices.
if options.Sparse && numVariants==1
    [syst, ~, deriv] = systemFirstOrder(this, 1, options);
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
        [syst, ~, deriv] = systemFirstOrder(this, v, options);
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

logPrefix = model.component.Quantity.LOG_PREFIX;
yVector = string(printSolutionVector(this, "y", logPrefix));
xVector0 = string(printSolutionVector(this, this.Vector.System{2}, logPrefix));
xVector1 = string(printSolutionVector(this, this.Vector.System{2}+1i, logPrefix));
eVector = string(printSolutionVector(this, "e", logPrefix));
mEquations = string(model.component.Equation.extractInput(this.Equation.Input(1:numM), "dynamic"));
tEquations = string(model.component.Equation.extractInput(this.Equation.Input(numM+(1:numT)), "dynamic"));
list = {yVector, xVector1, eVector, mEquations, tEquations};

% Number of forward-looking variables.
numF = sum( imag(this.Vector.System{2})>=0 );

if startsWith(string(options.MatrixFormat), "named", "ignoreCase", true)
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

