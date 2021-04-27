% prepareCheckSteady  Prepare stead state check
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function options = prepareCheckSteady(this, options)

arguments
    this %#ok<INUSA>

    options.Run (1, 1) logical = true
    options.Silent (1, 1) logical = false
    options.EquationSwitch (1, 1) string {mustBeMember(options.EquationSwitch, ["dynamic", "steady"])} = "dynamic"
    options.Error (1, 1) logical = true
    options.Warning (1, 1) logical = true
end

end%

