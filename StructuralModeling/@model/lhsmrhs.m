function dcy = lhsmrhs(this, varargin)
% lhsmrhs  Evaluate the discrepancy between the LHS and RHS for each model equation and given data.
%
% Syntax for casual evaluation
% =============================
%
%     Q = lhsmrhs(M, D, Range)
%
%
% Syntax for fast evaluation
% ===========================
%
%     Q = lhsmrhs(M, YXET)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose equations and currently assigned
% parameters will be evaluated.
%
% * `YXET` [ numeric ] - Numeric array created from an input database by
% calling the function [`data4lhsmrhs`](model/data4lhsmrhs). `YXET` contains
% data for measurement variables, transition variables, and shocks
% organised in rows, plus an extra last row with time shifts for
% steady-state references.
%
% * `D` [ struct ] - Input database with data for measurement variables,
% transition variables, and shocks on which the discrepancies will be
% evaluated.
%
% * `Range` [ numeric ] - Date range on which the discrepancies will be
% evaluated.
%
%
% Output arguments
% =================
%
% `Q` [ numeric ] - Numeric array with discrepancies between the LHS and
% RHS for each model equation.
%
%
% Description
% ============
%
% The function `lhsmrhs` evaluates the discrepancy between the LHS and the
% RHS in each model equation; each lead is replaced with the actual
% observation supplied in the input data. The function `lhsmrhs` does not
% work for models with [references to steady state
% values](modellang/sstateref).
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
% Example
% ========
%
%     YXET = data4lhsmrhs(M,d,range);
%     Q = lhsmrhs(M,YXET);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nAlt = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);
ixmt = ixm | ixt;

vecAlt = Inf;
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
        vecAlt = varargin{1};
        varargin(1) = [ ];
    end
elseif isstruct(varargin{1})
    % Casual syntax with input database.
    inp = varargin{1};
    varargin(1) = [ ];
    range = varargin{1};
    varargin(1) = [ ];
    if isempty(range)
        dcy = zeros(sum(ixmt), 0, nAlt);
        return
    end
    howToCreateL = [ ];
    YXEPG = data4lhsmrhs(this, inp, range);
end

opt = passvalopt('model.lhsmrhs', varargin{:});

if isequal(vecAlt, Inf) || isequal(vecAlt, @all)
    nAlt = length(this);
    vecAlt = 1 : nAlt;
end
nVecAlt = length(vecAlt);

[YXEPG, L] = lp4yxe(this, YXEPG, vecAlt, howToCreateL);

nXPer = size(YXEPG, 2);
if strcmpi(opt.kind, 'Dynamic')
    eqtn = this.Equation.Dynamic;
    minSh = this.Incidence.Dynamic.Shift(1);
    maxSh = this.Incidence.Dynamic.Shift(end);
else
    eqtn = this.Equation.Steady;
    ixCopy = ixmt & cellfun(@isempty, eqtn);
    eqtn(ixCopy) = this.Equation.Dynamic(ixCopy);
    minSh = this.Incidence.Steady.Shift(1);
    maxSh = this.Incidence.Steady.Shift(end);
end

temp = [ eqtn{ixmt} ];
temp = vectorize(temp);
fn = str2func([this.PREAMBLE_DYNAMIC, '[', temp, ']']);
t = 1-minSh : nXPer-maxSh;
dcy = [ ];
for iAlt = 1 : nVecAlt
    q = fn(YXEPG(:, :, iAlt), t, L(:, :, iAlt));
    dcy = cat(3, dcy, q);
end

end
