function opt = prepareCheckSteady(this, mode, varargin) %#ok<INUSL>
% prepareCheckSteady  Prepare steady-state check
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if numel(varargin)==1 && isequal(varargin{1}, false)
    opt = false;
    return
end

if numel(varargin)==1 && isequal(varargin{1}, true)
    varargin(1) = [ ];
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.prepareCheckSteady');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addRequired('Mode', @validateMode);
    parser.addParameter({'EquationSwitch', 'Kind', 'Type', 'Eqtn', 'Equation', 'Equations'}, 'Dynamic', @validateEquationSwitch);
end
parser.parse(this, mode, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

end%

%
% Validators
%

function flag = validateMode(value)
    if ~ischar(value) && ~(isa(value, 'string') && isscalar(value))
        flag = false;
        return
    end
    flag = any(strcmpi(value, {'Verbose', 'Silent'}));
end%


function flag = validateEquationSwitch(value)
    if ~ischar(value) && ~(isa(value, 'string') && isscalar(value))
        flag = false;
        return
    end
    flag = any(strcmpi(value, {'Dynamic', 'Full', 'Steady', 'SState'}));
end%

