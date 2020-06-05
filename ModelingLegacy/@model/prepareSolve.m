function opt = prepareSolve(this, mode, inputSolveOptions)
% prepareSolve  Prepare model solution
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

if nargin<3
    inputSolveOptions = cell.empty(1, 0);
else
    if isequal(inputSolveOptions, false)
        opt = false;
        return
    elseif isequal(inputSolveOptions, true)
        inputSolveOptions = cell.empty(1, 0);
    end
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('model.prepareSolve');
    addRequired(pp, 'Model', @(x) isa(x, 'model'));
    addRequired(pp, 'Mode', @ischar);
    addParameter(pp, {'Eqtn', 'Equations'}, @all, @(x) isequal(x, @all) || ischar(x));
    addParameter(pp, {'Normalize', 'Normalise'}, true, @(x) isequal(x, true) || isequal(x ,false));
    addParameter(pp, 'Select', true, @validate.logicalScalar);
    addParameter(pp, 'Symbolic', true, @validate.logicalScalar);
    addParameter(pp, 'Error', false, @validate.logicalScalar);
    addParameter(pp, 'Fast', false, @validate.logicalScalar);
    addParameter(pp, 'Progress', false, @validate.logicalScalar);
    addParameter(pp, 'Warning', true, @validate.logicalScalar);
end
%)
opt = parse(pp, this, mode, inputSolveOptions{:});

%--------------------------------------------------------------------------

if contains(mode, 'silent', 'IgnoreCase', true)
    opt.Progress = false;
    opt.Warning = false;
end

end%

