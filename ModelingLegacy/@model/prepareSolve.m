function opt = prepareSolve(this, mode, inputSolveOptions)
% prepareSolve  Prepare model solution
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

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

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model.prepareSolve');
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('Mode', @ischar);
    inputParser.addParameter({'Eqtn', 'Equations'}, @all, @(x) isequal(x, @all) || ischar(x));
    inputParser.addParameter({'Normalize', 'Normalise'}, true, @(x) isequal(x, true) || isequal(x ,false));
    inputParser.addParameter('Select', true, @(x) isequal(x, true) || isequal(x ,false));
    inputParser.addParameter('Symbolic', true, @(x) isequal(x, true) || isequal(x ,false));
    inputParser.addParameter('Error', false, @(x) isequal(x, true) || isequal(x ,false));
    inputParser.addParameter('Fast', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Warning', true, @(x) isequal(x, true) || isequal(x, false));
end
inputParser.parse(this, mode, inputSolveOptions{:});
opt = inputParser.Options;

%--------------------------------------------------------------------------

mode = lower(mode);

if ~isempty( strfind(mode, 'silent') )
    opt.Progress = false;
    opt.Warning = false;
end

end
