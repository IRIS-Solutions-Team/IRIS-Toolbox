function dcy = lhsmrhs(this, inputData, varargin)
% lhsmrhs  Discrepancy between the LHS and RHS of each model equation for given data
%
% ## Syntax for Casual Evaluation ##
%
%     Q = lhsmrhs(Model, InputDatabank, Range)
%
%
% ## Syntax for Fast Evaluation ##
%
%     Q = lhsmrhs(Model, X)
%
%
% ## Input Arguments ##
%
% * `Model` [ model ] - Model object whose equations and currently assigned
% parameters will be evaluated.
%
% * `X` [ numeric ] - Numeric array created from an input databank by
% calling the function [`data4lhsmrhs`](model/data4lhsmrhs). `X` contains
% data for all `Model` quantities (measurement variables, transition
% variables, shocks, parameters, and exogenous variables including a time
% trend) organised in rows, plus an extra last row with time shifts for
% steady-state references.
%
% * `InputDatabank` [ struct ] - Input databank with data for measurement
% variables, transition variables, and shocks on which the discrepancies
% will be evaluated.
%
% * `Range` [ numeric ] - Date range on which the discrepancies will be
% evaluated.
%
%
% ## Output Arguments ##
%
% `Q` [ numeric ] - Numeric array with discrepancies between the LHS and
% RHS for each model equation.
%
%
% ## Options ##
%
% `HashEquationsOnly=false` [ `true` | `false` ] - Evaluate hash equations
% only.
%
% `EquationSwitch='Dynamic'` [ `'Dynamic'` | `'Steady'` ] - Evaluate the
% dynamic versions or the steady versions of the model equations.
%
% 
% ## Description ##
%
% The function `lhsmrhs` evaluates the discrepancy between the LHS and the
% RHS in each model equation; each lead is replaced with the actual
% observation supplied in the input data. The function `lhsmrhs` does not
% work for models with [references to steady state
% values](irislang/sstateref).
%
% The first syntax, with the array `YXET` pre-built in a prior call to
% [`data4lhsmrhs`](model/data4lhsmrhs) is computationally more efficient if
% you need to evaluate the LHS-RHS discrepancies repeatedly for different
% parameterisations.
%
% The output argument `D` is an nEqtn-by-nPer-by-nAlt array, where nEqtn is
% the number of measurement and transition equations, nPer is the length of
% the range on which `lhsmrhs` is evaluated, and nAlt is the greater of
% the number of alternative parameterisations in `M`, and the number of
% alternative datasets in the input data, `D` or `YXET`.
%
%
% ## Example ##
%
%     YXET = data4lhsmrhs(M, d, range);
%     Q = lhsmrhs(M, YXET);
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.lhsmrhs');
    parser.addParameter('HashEquationsOnly', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'EquationSwitch', 'Kind'}, 'Dynamic', @(x) any(strcmpi(x, {'Dynamic', 'Steady'})));
end

%--------------------------------------------------------------------------

nv = length(this);
inxOfM = this.Equation.Type==TYPE(1);
inxOfT = this.Equation.Type==TYPE(2);
inxOfEquations = inxOfM | inxOfT;

variantsRequested = Inf;
if isnumeric(inputData)
    % Fast syntax with numeric array
    YXEPG = inputData;
    howToCreateL = [ ];
    if ~isempty(varargin)
        howToCreateL = varargin{1};
        varargin(1) = [ ];
    end
    if ~isempty(varargin)
        variantsRequested = varargin{1};
        varargin(1) = [ ];
    end
elseif isstruct(inputData)
    % Casual syntax with input databank
    range = varargin{1};
    varargin(1) = [ ];
    range = double(range);
    if isempty(range)
        dcy = zeros(nnz(inxOfEquations), 0, nv);
        return
    end
    howToCreateL = [ ];
    YXEPG = data4lhsmrhs(this, inputData, range);
end

parse(parser, varargin{:});
opt = parser.Options;

if opt.HashEquationsOnly
    inxOfEquations = inxOfEquations & this.Equation.InxOfHashEquations;
end

if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    nv = length(this);
    variantsRequested = 1 : nv;
end
numOfVariantsRequested = numel(variantsRequested);

% Update parameters and steady levels
[YXEPG, L] = lp4lhsmrhs(this, YXEPG, variantsRequested, howToCreateL);

nXPer = size(YXEPG, 2);
if strcmpi(opt.EquationSwitch, 'Dynamic')
    eqtn = this.Equation.Dynamic;
else
    eqtn = this.Equation.Steady;
    inxToCopy = inxOfEquations & cellfun(@isempty, eqtn);
    eqtn(inxToCopy) = this.Equation.Dynamic(inxToCopy);
end

[minSh, maxSh] = getActualMinMaxShifts(this);

temp = [ eqtn{inxOfEquations} ];
temp = vectorize(temp);
fn = str2func([this.PREAMBLE_DYNAMIC, '[', temp, ']']);
t = 1-minSh : nXPer-maxSh;
dcy = [ ];
for v = 1 : numOfVariantsRequested
    try
    q = fn(YXEPG(:, :, v), t, L(:, :, v));
    catch, s = char(fn); keyboard, end
    dcy = cat(3, dcy, q);
end

end%

