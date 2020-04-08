function this = symbDiff(this, optSymbDiff)
% symbDiff  Evaluate symbolic derivatives for model equations
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

TYPE = @int8;
PTR = @int16;

try, optSymbDiff; catch, optSymbDiff = true; end %#ok<VUNUS,NOCOM>
if iscell(optSymbDiff)
    optSymbDiff = passvalopt('model.symbdiff', optSymbDiff{:});
elseif isequal(optSymbDiff, true)
    optSymbDiff = passvalopt('model.symbdiff');
end

%--------------------------------------------------------------------------

inxM = this.Equation.Type==TYPE(1);
inxT = this.Equation.Type==TYPE(2);
inxD = this.Equation.Type==TYPE(3);
inxL = this.Equation.Type==TYPE(4);

inxP = this.Quantity.Type==TYPE(4);
inxG = this.Quantity.Type==TYPE(5);
inxPG = inxP | inxG;

% Reset gradient object.
numEquations = numel(this.Equation);
this.Gradient = model.component.Gradient(numEquations);

%
% Deterministic Trends
%

% Differentiate dtrends w.r.t. parameters and exogenous variables.
for iEq = find(inxD)
    vecWrt = find(this.Incidence.Dynamic, iEq, inxPG);
    eqtn = this.Equation.Dynamic{iEq};
    d = model.component.Gradient.diff(eqtn, vecWrt, 'cell');
    % Derivatives of dtrends must be vectorized ./ .* .^ because they will be
    % evaluated on vectors of inputs (ttrend, etc.), unlike other derivatives.
    d = cellfun(@vectorize, d, 'UniformOutput', false);
    this.Gradient.Dynamic(:, iEq) = {d; vecWrt};
end


%
% Measurement and Transition Equations, Dynamic Links
%

% Differentiate equations w.r.t. variables and shocks
inxYXE = this.Quantity.Type==TYPE(1) ...
    | this.Quantity.Type==TYPE(2) ...
    | this.Quantity.Type==TYPE(31) ...
    | this.Quantity.Type==TYPE(32);

for iEq = find(inxM | inxT | inxL)
    % Differentiate one equation wrt all names at a time. The result will be
    % a single vector of derivatives.
    vecWrt = find(this.Incidence.Dynamic, iEq, inxYXE);
    d = [ ];
    if ~isequal(optSymbDiff, false)
        d = model.component.Gradient.diff(this.Equation.Dynamic{iEq}, vecWrt);    
    end
    this.Gradient.Dynamic(:, iEq) = {d; vecWrt};
    if ~isempty(this.Equation.Steady{iEq})
        vecWrt = find(this.Incidence.Steady, iEq, inxYXE);
        d = [ ];
        if ~isequal(optSymbDiff, false)
            d = model.component.Gradient.diff(this.Equation.Steady{iEq}, vecWrt);
        end
        this.Gradient.Steady(:, iEq) = {d; vecWrt};
    end
end

end%

