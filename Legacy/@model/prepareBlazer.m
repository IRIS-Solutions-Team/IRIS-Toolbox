% prepareBlazer  Create Blazer object from dynamic or steady equations
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function prepareBlazer(this, blz)

inxY = this.Quantity.Type==1;
inxX = this.Quantity.Type==2;
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;
inxP = this.Quantity.Type==4;
inxM = this.Equation.Type==1;
inxT = this.Equation.Type==2;
inxYX = inxY | inxX;
inxMT = inxM | inxT;

classBlazer = string(class(blz));

if all(strcmpi(classBlazer, 'solver.blazer.Steady'))
    %
    % Steady state solution
    %

    [inxPwL, inxLwP] = here_getParameterLinks( ); % [^1] [^2]
    %
    % [^1]: inxPwL is the index of parameters that are LHS names in links
    %
    % [^2]: inxLwP is the index of equations that are links with parameters on
    % the LHS

    blz.InxEndogenous = inxYX | inxPwL;
    blz.InxEquations = inxMT | inxLwP ;
    blz.InxCanBeEndogenized = inxP & ~inxPwL;
    blz.InxCanBeExogenized = blz.InxEndogenous;

    blz.Equations(blz.InxEquations) = this.Equation.Steady(blz.InxEquations);
    inxCopy = blz.InxEquations & cellfun('isempty', this.Equation.Steady(1, :));        
    blz.Equations(inxCopy) = this.Equation.Dynamic(inxCopy);
    blz.Gradients(:, inxMT) = this.Gradient.Steady(:, inxMT);
    blz.Gradients(:, inxCopy) = this.Gradient.Dynamic(:, inxCopy);
    blz.Incidence = this.Incidence.Steady;
    blz.Assignments = this.Pairing.Assignments.Steady;

    blz.EquationsToExclude = find(inxLwP);
    blz.QuantitiesToExclude = find(inxPwL);


elseif all(strcmpi(classBlazer, 'solver.blazer.Period'))
    %
    % Period by period simulations
    % 
    blz.InxEndogenous = inxYX;
    blz.InxEquations = inxMT;
    blz.InxCanBeEndogenized = inxE;
    blz.InxCanBeExogenized = blz.InxEndogenous;

    blz.Equations(blz.InxEquations) = this.Equation.Dynamic(blz.InxEquations);
    blz.Gradients(:, :) = this.Gradient.Dynamic;
    blz.Incidence = selectShift(this.Incidence.Dynamic, 0);
    blz.Assignments = this.Pairing.Assignments.Dynamic;


elseif all(strcmpi(classBlazer, 'solver.blazer.Stacked'))
    %
    % Stacked time simulation
    %
    blz.InxEndogenous = inxYX;
    blz.InxEquations = inxMT;
    blz.InxCanBeEndogenized = inxE;
    blz.InxCanBeExogenized = blz.InxEndogenous;

    blz.Equations(blz.InxEquations) = this.Equation.Dynamic(blz.InxEquations);
    blz.Gradients(:, :) = this.Gradient.Dynamic;
    blz.Incidence = this.Incidence.Dynamic;
    blz.Assignments = this.Pairing.Assignments.Dynamic;

elseif all(strcmpi(classBlazer, 'solver.blazer.Selective'))
    %
    % Legacy equation selective simulation
    %
    return

else
    %
    % No Blazer needed
    %
    return

end

blz.Model.Quantity = this.Quantity;
blz.Model.Equation = this.Equation;

return

    function [inxPwL, inxLwP] = here_getParameterLinks( )
        numEquations = countEquations(this);
        numQuantities = countQuantities(this);
        inxL = this.Equation.Type==4;
        numL = nnz(inxL);
        inxPwL = false(1, numQuantities); % [^1]
        inxLwP = false(1, numEquations); % [^2]
        % [^1]: Index of parameters that occur on the LHS of a link
        % {^2]: Index of links that have a parameter on the LHS
        if isempty(this.Link)
            return
        end
        % LHS pointers to parameters; inactive links (LhsPtr<0) are
        % automatically excluded from the intersection
        [posPwL, pos] = intersect(this.Link.LhsPtr, find(inxP));
        if isempty(posPwL)
            return
        end
        inxPwL(posPwL) = true;
        % Index of links that have a parameter on the LHS
        inx = false(1, numL);
        inx(pos) = true;
        inxLwP(inxL) = inx;
    end%
end%

%
% Local Functions
%

function flag = local_validateLogList(input)
    %(
    if isempty(input)
        flag = true;
        return
    end
    if isequal(input, @all)
        flag = true;
        return
    end
    if ischar(input) || iscellstr(input) || isstring(input)
        flag = true;
        return
    end
    flag = false;
    %)
end%

