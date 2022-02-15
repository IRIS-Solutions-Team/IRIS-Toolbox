% prepareSolve  Prepare model solution
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function options = prepareSolve(this, options)

arguments
    this %#ok<INUSA>

    options.Run (1, 1) logical = true

    options.Silent (1, 1) logical = false
    options.Equations = ""
    options.Normalize (1, 1) logical = true
    options.PreferredSchur (1, 1) string {mustBeMember(options.PreferredSchur, ["schur", "qz"])} = "qz"
    options.ForceDiff (1, 1) logical = false
    options.MatrixFormat = "plain"
    options.Symbolic (1, 1) logical = true
    options.Error (1, 1) logical = false
    options.Progress (1, 1) logical = false
    options.Warning (1, 1) logical = true
end
%)
% >=R2019b


% <=R2019a
%{
function options = prepareSolve(this, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser("Model/prepareSolve");
    addParameter(pp, "Run", true, @validate.logicalScalar);
    addParameter(pp, "Silent", false, @validate.logicalScalar);
    addParameter(pp, "Equations", "");
    addParameter(pp, "Normalize", true, @validate.logicalScalar);
    addParameter(pp, "PreferredSchur", "qz", @(x) mustBeMember(x, ["schur", "qz"]));
    addParameter(pp, "ForceDiff", false, @validate.logicalScalar);
    addParameter(pp, "MatrixFormat", "plain");
    addParameter(pp, "Symbolic", true, @validate.logicalScalar);
    addParameter(pp, "Error", false, @validate.logicalScalar);
    addParameter(pp, "Progress", false, @validate.logicalScalar);
    addParameter(pp, "Warning", true, @validate.logicalScalar);
end
options = parse(pp, varargin{:});
%}
% <=R2019a


if options.Silent
    options.Progress = false;
    options.Warning = false;
end

end%

