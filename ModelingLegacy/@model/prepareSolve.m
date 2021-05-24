% prepareSolve  Prepare model solution
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%{
function options = prepareSolve(this, options)

arguments
    this %#ok<INUSA>

    options.Run (1, 1) logical = true
    options.Silent (1, 1) logical = false
    options.Equations = ""
    options.Normalize (1, 1) logical = true
    options.PreferredSchur (1, 1) string {mustBeMember(options.PreferredSchur, ["schur", "qz"])} = "schur"
    options.Select (1, 1) logical = true
    options.Symbolic (1, 1) logical = true
    options.Error (1, 1) logical = false
    options.Progress (1, 1) logical = false
    options.Warning (1, 1) logical = true
end
%}
% >=R2019b


% <=R2019a
%(
function options = prepareSolve(this, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser("Model/prepareSolve");
    addParameter(inputParser, "Run", true, @validate.logicalScalar);
    addParameter(inputParser, "Silent", false, @validate.logicalScalar);
    addParameter(inputParser, "Equations", "");
    addParameter(inputParser, "Normalize", true, @validate.logicalScalar);
    addParameter(inputParser, "PreferredSchur", "schur", @(x) mustBeMember(x, ["schur", "qz"]));
    addParameter(inputParser, "Select", true, @validate.logicalScalar);
    addParameter(inputParser, "Symbolic", true, @validate.logicalScalar);
    addParameter(inputParser, "Error", false, @validate.logicalScalar);
    addParameter(inputParser, "Progress", false, @validate.logicalScalar);
    addParameter(inputParser, "Warning", true, @validate.logicalScalar);
end
options = parse(inputParser, varargin{:});
%)
% <=R2019a


if options.Silent
    options.Progress = false;
    options.Warning = false;
end

end%

