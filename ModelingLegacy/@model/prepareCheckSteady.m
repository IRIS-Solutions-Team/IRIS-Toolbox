% prepareCheckSteady  Prepare stead state check
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function options = prepareCheckSteady(this, options)

arguments
    this %#ok<INUSA>

    options.Run (1, 1) logical = true
    options.Silent (1, 1) logical = false
    options.EquationSwitch (1, 1) string {mustBeMember(options.EquationSwitch, ["dynamic", "steady"])} = "dynamic"
    options.Error (1, 1) logical = true
    options.Warning (1, 1) logical = true
end
%)
% >=R2019b


% <=R2019a
%{
function options = prepareCheckSteady(this, varargin)

persistent inputParser
if isempty(inputParser)
    addOptional(inputParser, "Run", true, @validate.logicalScalar);
    addOptional(inputParser, "Silent", false, @validate.logicalScalar);
    addOptional(inputParser, "EquationSwitch", "dynamic", @(x) mustBeMember(x, ["dynamic", "steady"]));
    addOptional(inputParser, "Error", true, @validate.logicalScalar);
    addOptional(inputParser, "Warning", true, @validate.logicalScalar);
end
options = parse(inputParser, varargin{:});
%}
% <=R2019a

end%

