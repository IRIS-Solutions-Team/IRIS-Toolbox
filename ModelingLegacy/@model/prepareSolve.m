% prepareSolve  Prepare model solution
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function options = prepareSolve(this, options)

% >=R2019b
%(
arguments
    this %#ok<INUSA>
    options.Silent (1, 1) logical = false
    options.Run (1, 1) logical = true
    options.Equations = ""
    options.Normalize (1, 1) logical = true
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

