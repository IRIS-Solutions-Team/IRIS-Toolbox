%{
% 
% # `systemMatrices` ^^(Model)^^
% 
% {== First-order system matrices describing the unsolved model ==}
% 
% 
% ## Syntax
% 
%     output = systemMatrices(model)
% 
% 
% ## Input Arguments
% 
% __`model`__ [ Model ] 
% > 
% > Model object whose system matrices will be
% > returned.
% > 
% 
% ## Output Arguments
% 
% __`output`__ [ struct ]
% > 
% > Output struct with the matrices describing the unsolved system, see
% > Description.
% > 
% 
% 
% __`numF`__ [ numeric ] 
% > 
% > Number of non-predetermined (aka forward-looking) transition variables
% > (multiplied by the first `numF` columns of matrices `A` and `B`).
% > 
% 
% ## Options
% 
% __`ForceDiff=false`__ [ `true` | `false` ] 
% > 
% > If `false`, automatically detect which equations need to be
% > re-differentiated based on parameter changes from the last time the
% > system matrices were calculated; if `true`, recalculate all derivatives.
% > 
% 
% __`MatrixFormat="NamedMatrix"`__ [ `"plain"` | `"NamedMatrix"` ]
% > 
% > Format of the output matrix.
% > 
% 
% __`Normalize=true`__ [ `true` | `false` ]
% > 
% > Normalize (divide) the derivatives within each equation by the largest of
% > them.
% > 
% 
% __`Sparse=false`__ [ `true` | `false` ] 
% > 
% > Return the system matrices `output.A`, `output.B`, `output.D`,
% > `output.F`, `output.G`, and `output.J` as sparse matrices; this option
% > can be `true` only in models with one parameterization.
% > 
% 
% 
% ## Description
% 
% The `output` struct contains the following fields:
% 
% * `.A`, `.B`, `.C`, `.D` - matrices (plain arrays or or NamedMat objects,
%   depending on the option `MatrixFormat`) describing the first-order
%   expansion of transition equations around steady state;
% 
% * `.F`, `.G`, `.H`, `.J` - matrices (plain arrays or or NamedMat objects,
%   depending on the option `MatrixFormat`) describing the first-order
%   expansion of measurement equations around steady state;
% 
% * `.NumForward` - the number of non-predetermined (forward-looking)
%   variables in the transition vector;
% 
% * `.NumBackward` - the number of predetermined (backward-looking)
%   variables in the transition vector;
% 
% 
% The system before the model is solved has the following form:
% 
%     A E[xf;xb] + B [xf(-1);xb(-1)] + C + D e = 0
% 
%     F y + G xb + H + J e = 0
% 
% where 
% 
% * `E` is a conditional expectations operator;
% 
% * `xf` is a vector of non-predetermined (forward-looking) transition
%   variables;
% 
% * `xb` is a vector of predetermined (backward-looking) transition
%   variables;
% 
% * `y` is a vector of measurement variables
% 
% * `e` is a vector of transition and measurement shocks.
% 
% 
% ## Example
%}
% --8<--


% >=R2019b
%{
function output = systemMatrices(this, opt)

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
function output = system(this, varargin)

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

    numVariants = countVariants(this);
    numM = nnz(this.Equation.Type==1);
    numT = nnz(this.Equation.Type==2);

    if opt.Sparse && numVariants>1
        exception.error([
            "Model"
            "Cannot return sparse system matrices for models "
            "with multiple parameter variants. "
        ]);
    end


    output = struct();

    % Number of forward- and backward-looking variables
    output.NumForward = sum(imag(this.Vector.System{2})>=0);
    output.NumBackward = numel(this.Vector.System{2}) - output.NumForward;

    if opt.Sparse && numVariants==1
        [system, ~, ~] = systemFirstOrder(this, 1, opt);
        output.F = system.A{1}; %#ok<*AGROW>
        output.G = system.B{1};
        output.H = system.K{1};
        output.J = system.E{1};
        output.A = system.A{2};
        output.B = system.B{2};
        output.C = system.K{2};
        output.D = system.E{2};
    else
        for v = 1 : numVariants
            [system, ~, ~] = systemFirstOrder(this, v, opt);
            output.F(:, :, v) = full(system.A{1}); %#ok<*AGROW>
            output.G(:, :, v) = full(system.B{1});
            output.H(:, 1, v) = full(system.K{1});
            output.J(:, :, v) = full(system.E{1});
            output.A(:, :, v) = full(system.A{2});
            output.B(:, :, v) = full(system.B{2});
            output.C(:, 1, v) = full(system.K{2});
            output.D(:, :, v) = full(system.E{2});
        end
    end

    logPrefix = model.Quantity.LOG_PREFIX;
    yVector = string(printSolutionVector(this, "y", logPrefix));
    xVector0 = string(printSolutionVector(this, this.Vector.System{2}, logPrefix));
    xVector1 = string(printSolutionVector(this, this.Vector.System{2}+1i, logPrefix));
    xVectorB1 = xVector1(output.NumForward+1:end);
    eVector = string(printSolutionVector(this, "e", logPrefix));
    mEquations = string(model.Equation.extractInput(this.Equation.Input(1:numM), "dynamic"));
    tEquations = string(model.Equation.extractInput(this.Equation.Input(numM+(1:numT)), "dynamic"));

    numIdentities = size(output.A, 1) - numT;
    tEquations = [tEquations, "Identity_"+string(1:numIdentities)];

    output.XVector = xVector0;
    output.YVector = yVector;
    output.EVector = eVector;
    output.TEquations = tEquations;
    output.MEquations = mEquations;

    if startsWith(string(opt.MatrixFormat), "named", "ignoreCase", true)
        output.A = namedmat(output.A, tEquations, xVector1);
        output.B = namedmat(output.B, tEquations, xVector0);
        output.C = namedmat(output.C, tEquations, this.INTERCEPT_STRING);
        output.D = namedmat(output.D, tEquations, eVector);
        output.F = namedmat(output.F, mEquations, yVector);
        output.G = namedmat(output.G, mEquations, xVectorB1);
        output.H = namedmat(output.H, mEquations, this.INTERCEPT_STRING);
        output.J = namedmat(output.J, mEquations, eVector);
    end

end%

