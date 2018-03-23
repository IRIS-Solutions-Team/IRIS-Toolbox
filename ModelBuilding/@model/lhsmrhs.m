function dcy = lhsmrhs(this, varargin)
% lhsmrhs  Discrepancy between the LHS and RHS of each model equation for given data.
%
% __Syntax for Casual Evaluation__
%
%     Q = lhsmrhs(Model, InputDatabank, Range)
%
%
% __Syntax for Fast Evaluation__
%
%     Q = lhsmrhs(Model, X)
%
%
% __Input Arguments__
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
% __Output Arguments__
%
% `Q` [ numeric ] - Numeric array with discrepancies between the LHS and
% RHS for each model equation.
%
%
% __Description__
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
% __Example__
%
%     YXET = data4lhsmrhs(M, d, range);
%     Q = lhsmrhs(M, YXET);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nv = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);
ixmt = ixm | ixt;

variantsRequested = Inf;
if isnumeric(varargin{1})
    % Fast syntax with numeric array.
    YXEPG = varargin{1};
    varargin(1) = [ ];
    howToCreateL = [ ];
    if ~isempty(varargin)
        howToCreateL = varargin{1};
        varargin(1) = [ ];
    end
    if ~isempty(varargin)
        variantsRequested = varargin{1};
        varargin(1) = [ ];
    end
elseif isstruct(varargin{1})
    % Casual syntax with input databank.
    inp = varargin{1};
    varargin(1) = [ ];
    range = varargin{1};
    varargin(1) = [ ];
    if isempty(range)
        dcy = zeros(sum(ixmt), 0, nv);
        return
    end
    howToCreateL = [ ];
    YXEPG = data4lhsmrhs(this, inp, range);
end

opt = passvalopt('model.lhsmrhs', varargin{:});

if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    nv = length(this);
    variantsRequested = 1 : nv;
end
numOfVariantsRequested = numel(variantsRequested);

% Update parameters and steady levels.
[YXEPG, L] = lp4lhsmrhs(this, YXEPG, variantsRequested, howToCreateL);

nXPer = size(YXEPG, 2);
if strcmpi(opt.kind, 'Dynamic')
    eqtn = this.Equation.Dynamic;
else
    eqtn = this.Equation.Steady;
    indexToCopy = ixmt & cellfun(@isempty, eqtn);
    eqtn(indexToCopy) = this.Equation.Dynamic(indexToCopy);
end

[minSh, maxSh] = getActualMinMaxShifts(this);

temp = [ eqtn{ixmt} ];
temp = vectorize(temp);
fn = str2func([this.PREAMBLE_DYNAMIC, '[', temp, ']']);
t = 1-minSh : nXPer-maxSh;
dcy = [ ];
for v = 1 : numOfVariantsRequested
    q = fn(YXEPG(:, :, v), t, L(:, :, v));
    dcy = cat(3, dcy, q);
end

end
