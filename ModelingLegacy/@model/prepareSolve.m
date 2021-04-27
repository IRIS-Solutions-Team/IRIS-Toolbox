% prepareSolve  Prepare model solution
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function options = prepareSolve(this, options)

% >=R2019b
%(
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
%)
% >=R2019b

if options.Silent
    options.Progress = false;
    options.Warning = false;
end

end%

