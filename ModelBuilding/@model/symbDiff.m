function this = symbDiff(this, optSymbDiff)
% symbDiff  Evaluate symbolic derivatives for model equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;
PTR = @int16;

try, optSymbDiff; catch, optSymbDiff = true; end %#ok<VUNUS,NOCOM>
if iscell(optSymbDiff)
    optSymbDiff = passvalopt('model.symbdiff', optSymbDiff{:});
elseif isequal(optSymbDiff, true)
    optSymbDiff = passvalopt('model.symbdiff');
end

%--------------------------------------------------------------------------

ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);
ixd = this.Equation.Type==TYPE(3);
ixp = this.Quantity.Type==TYPE(4);
ixg = this.Quantity.Type==TYPE(5);
ixpg = ixp | ixg;

% Reset gradient object.
nEqtn = numel(this.Equation.Input);
this.Gradient = model.component.Gradient(nEqtn);

% __Deterministic Trends__
% Differentiate dtrends w.r.t. parameters and exogenous variables.
for iEq = find(ixd)
    vecWrt = find(this.Incidence.Dynamic, iEq, ixpg);
    eqtn = this.Equation.Dynamic{iEq};
    d = model.component.Gradient.diff(eqtn, vecWrt, 'cell');
    % Derivatives of dtrends must be vectorized ./ .* .^ because they will be
    % evaluated on vectors of inputs (ttrend, etc.), unlike other derivatives.
    d = cellfun(@vectorize, d, 'UniformOutput', false);
    this.Gradient.Dynamic(:, iEq) = {d; vecWrt};
end

% __Measurement and Transition Equations__
% Differentiate equations w.r.t. variables and shocks.
indexYXE = this.Quantity.Type==TYPE(1) ...
    | this.Quantity.Type==TYPE(2) ...
    | this.Quantity.Type==TYPE(31) ...
    | this.Quantity.Type==TYPE(32);

for iEq = find(ixm | ixt)
    % Differentiate one equation wrt all names at a time. The result will be
    % a single vector of derivatives.
    vecWrt = find(this.Incidence.Dynamic, iEq, indexYXE);
    d = [ ];
    if ~isequal(optSymbDiff, false)
        d = model.component.Gradient.diff(this.Equation.Dynamic{iEq}, vecWrt);    
    end
    this.Gradient.Dynamic(:, iEq) = {d; vecWrt};
    if ~isempty(this.Equation.Steady{iEq})
        vecWrt = find(this.Incidence.Steady, iEq, indexYXE);
        d = [ ];
        if ~isequal(optSymbDiff, false)
            d = model.component.Gradient.diff(this.Equation.Steady{iEq}, vecWrt);
        end
        this.Gradient.Steady(:, iEq) = {d; vecWrt};
    end
end

end
