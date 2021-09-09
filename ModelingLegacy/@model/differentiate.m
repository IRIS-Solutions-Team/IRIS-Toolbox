% differentiate  Evaluate symbolic gradients of model equations
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function this = differentiate(this, symbolic)

TYPE = @int8;
PTR = @int16;

try, symbolic; 
    catch, symbolic = true; end %#ok<VUNUS,NOCOM>

%--------------------------------------------------------------------------

inxM = this.Equation.Type==TYPE(1);
inxT = this.Equation.Type==TYPE(2);
inxD = this.Equation.Type==TYPE(3);
inxL = this.Equation.Type==TYPE(4);
inxMT = inxM | inxT;

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
    this.Gradient.Dynamic(1:2, iEq) = {d; reshape(vecWrt, 1, [ ])};
end


%
% Measurement and Transition Equations, Dynamic Links
%

% Differentiate equations w.r.t. variables and shocks
inxYXE = this.Quantity.Type==TYPE(1) ...
    | this.Quantity.Type==TYPE(2) ...
    | this.Quantity.Type==TYPE(31) ...
    | this.Quantity.Type==TYPE(32);

for iEq = find(inxMT)
    % Differentiate one equation wrt all names at a time; the result of
    % calling the function will be a single vector of derivatives
    vecWrt = reshape(find(this.Incidence.Dynamic, iEq, inxYXE), 1, [ ]);
    d = [ ];
    idsWithinGradient = [ ];
    if ~isequal(symbolic, false)
        d = model.component.Gradient.diff(this.Equation.Dynamic{iEq}, vecWrt);    
        idsWithinGradient = model.component.Gradient.lookupIdsWithinGradient(d);
        d = model.component.Gradient.repmatGradient(d);
    end
    this.Gradient.Dynamic(:, iEq) = {d; vecWrt; idsWithinGradient};

    if ~isempty(this.Equation.Steady{iEq})
        vecWrt = reshape(find(this.Incidence.Steady, iEq, inxYXE), 1, [ ]);
        d = [ ];
        idsWithinGradient = [ ];
        if ~isequal(symbolic, false)
            d = model.component.Gradient.diff(this.Equation.Steady{iEq}, vecWrt);
            idsWithinGradient = model.component.Gradient.lookupIdsWithinGradient(d);
            d = model.component.Gradient.repmatGradient(d);
        end
        this.Gradient.Steady(:, iEq) = {d; vecWrt; idsWithinGradient};
    end
end


%
% Differentiate dynamic links
%
for iEq = find(inxL)
    vecWrt = find(this.Incidence.Dynamic, iEq, inxYXE);
    d = [ ];
    if ~isequal(symbolic, false) && ~isempty(this.Equation.Dynamic{iEq}) 
        d = model.component.Gradient.diff(this.Equation.Dynamic{iEq}, vecWrt);    
    end
    this.Gradient.Dynamic(1:2, iEq) = {d; reshape(vecWrt, 1, [ ])};
    this.Gradient.Steady(1:2, iEq) = {d; reshape(vecWrt, 1, [ ])};
end


%
% Convert model equations to anonymous functions
%
this = myeqtn2afcn(this);

end%

%
% Local Functions
%


