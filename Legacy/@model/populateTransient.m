% populateTransient  Recreate transient properties in model object
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = populateTransient(this)

this.Quantity = populateTransient(this.Quantity);
this.Equation = populateTransient(this.Equation);

numQuantities = numel(this.Quantity.Name);
numY = sum(this.Quantity.Type==1);
numX = sum(this.Quantity.Type==2);
numE = sum(this.Quantity.Type==31 | this.Quantity.Type==32);
numYXE = numY + numX + numE;

% Reset handle object to last system info
resetLastSystem( );

% Create logical array for detecting equations affected by changes in
% parameters and/or steady-state values
this = createAffected(this);

return


    function resetLastSystem( )
        % Reset LastSystem to a new model.LastSystem handle object.
        this.LastSystem = model.LastSystem( );

        % __Parameters and steady states__
        this.LastSystem.Values = nan(1, numQuantities);

        % __Derivatives__
        numDerivatives = numYXE*this.Incidence.Dynamic.NumShifts;
        nEqtn12 = sum(this.Equation.Type<=(2));
        deriv = struct( );
        deriv.c = zeros(nEqtn12, 1);
        deriv.f = sparse(nEqtn12, numDerivatives);
        tempEye = -eye(nEqtn12);
        deriv.n = tempEye(:,this.Equation.IxHash);
        this.LastSystem.Deriv = deriv;

        % __System matrices__
        % Sizes of system matrices (different from solution matrices).
        [~, numXi, numXib] = sizeSystem(this.Vector);
        system = struct( );
        system.K{1} = zeros(numY, 1);
        system.K{2} = zeros(numXi, 1);
        system.A{1} = sparse(numY, numY);
        system.B{1} = sparse(numY, numXib);
        system.E{1} = sparse(numY, numE);
        system.N{1} = [ ];
        system.A{2} = sparse(numXi, numXi);
        system.B{2} = sparse(numXi, numXi);
        system.E{2} = sparse(numXi, numE);
        system.N{2} = zeros(numXi, sum(this.Equation.IxHash));
        this.LastSystem.System = system;
    end%
end%

