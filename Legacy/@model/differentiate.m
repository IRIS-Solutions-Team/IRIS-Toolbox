function gradient = differentiate(this, options)

%
% options.Symbolic [ true | false ]
% options.DiffOutput [ "array" | "cell" ]
%

inxM = this.Equation.Type==1;
inxT = this.Equation.Type==2;
inxD = this.Equation.Type==3;
inxL = this.Equation.Type==4;
inxMT = inxM | inxT;

inxP = this.Quantity.Type==4;
inxG = this.Quantity.Type==5;
inxPG = inxP | inxG;

% Reset gradient object
numEquations = numel(this.Equation);
gradient = model.Gradient(numEquations);

%
% Measurment trends
%

% Differentiate measurement trends w.r.t. parameters and exogenous variables
for iEq = find(inxD)
    vecWrt = find(this.Incidence.Dynamic, iEq, inxPG);
    eqtn = this.Equation.Dynamic{iEq};
    d = model.Gradient.diff(eqtn, vecWrt, "cell");
    % Derivatives of measurement trends must be vectorized ./ .* .^ because they will be
    % evaluated on vectors of inputs (ttrend, etc.), unlike other derivatives.
    for i = 1 : numel(d)
        d{i} = vectorize(d{i});
    end
    gradient.Dynamic(1:2, iEq) = {d; reshape(vecWrt, 1, [ ])};
end


%
% Measurement and transition equations, dynamic links
%

% Differentiate equations w.r.t. variables and shocks
inxYXE = this.Quantity.Type==1 ...
    | this.Quantity.Type==2 ...
    | this.Quantity.Type==31 ...
    | this.Quantity.Type==32;

for iEq = find(inxMT)
    % Differentiate one equation wrt all names at a time; the result of
    % calling the function will be a single vector of derivatives
    vecWrt = reshape(find(this.Incidence.Dynamic, iEq, inxYXE), 1, [ ]);
    d = [ ];
    idsWithinGradient = [ ];
    if ~isequal(options.Symbolic, false)
        d = model.Gradient.diff(this.Equation.Dynamic{iEq}, vecWrt, options.DiffOutput);
        if string(options.DiffOutput)=="array"
            idsWithinGradient = model.Gradient.lookupIdsWithinGradient(d);
            d = model.Gradient.repmatGradient(d);
        end
    end
    gradient.Dynamic(:, iEq) = {d; vecWrt; idsWithinGradient};

    if ~isempty(this.Equation.Steady{iEq})
        vecWrt = reshape(find(this.Incidence.Steady, iEq, inxYXE), 1, [ ]);
        d = [ ];
        idsWithinGradient = [ ];
        if ~isequal(options.Symbolic, false)
            d = model.Gradient.diff(this.Equation.Steady{iEq}, vecWrt, options.DiffOutput);
            if string(options.DiffOutput)=="array"
                idsWithinGradient = model.Gradient.lookupIdsWithinGradient(d);
                d = model.Gradient.repmatGradient(d);
            end
        end
        gradient.Steady(:, iEq) = {d; vecWrt; idsWithinGradient};
    end
end


%
% Differentiate dynamic links
%
for iEq = find(inxL)
    vecWrt = find(this.Incidence.Dynamic, iEq, inxYXE);
    d = [ ];
    if ~isequal(options.Symbolic, false) && ~isempty(this.Equation.Dynamic{iEq}) 
        d = model.Gradient.diff(this.Equation.Dynamic{iEq}, vecWrt, options.DiffOutput);
    end
    gradient.Dynamic(1:2, iEq) = {d; reshape(vecWrt, 1, [ ])};
    gradient.Steady(1:2, iEq) = {d; reshape(vecWrt, 1, [ ])};
end

end%

