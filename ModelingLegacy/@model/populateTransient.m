function this = populateTransient(this)
% populateTransient  Recreate transient properties in model object
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

numOfQuantities = length(this.Quantity.Name);
ny = sum(this.Quantity.Type==TYPE(1));
nx = sum(this.Quantity.Type==TYPE(2));
ne = sum(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));
nyxe = ny + nx + ne;

% Reset handle object to last system info
resetLastSystem( );

% Create logical array for detecting equations affected by changes in
% parameters and/or steady-state values
this = createAffected(this);

return


    function resetLastSystem( )
        TYPE = @int8;
        % Reset LastSystem to a new model.component.LastSystem handle object.
        this.LastSystem = model.component.LastSystem( );
        
        % Parameters and steady states
        %------------------------------
        this.LastSystem.Values = nan(1, numOfQuantities);
        
        % Derivatives
        %-------------
        numOfDerivatives = nyxe*this.Incidence.Dynamic.NumOfShifts;
        nEqtn12 = sum(this.Equation.Type<=TYPE(2));
        deriv = struct( );
        deriv.c = zeros(nEqtn12, 1);
        deriv.f = sparse(nEqtn12, numOfDerivatives);
        tempEye = -eye(nEqtn12);
        deriv.n = tempEye(:,this.Equation.IxHash);
        this.LastSystem.Deriv = deriv;

        % System matrices
        %-----------------
        % Sizes of system matrices (different from solution matrices).
        [~, kxx, kb] = sizeOfSystem(this.Vector);
        system = struct( );
        system.K{1} = zeros(ny, 1);
        system.K{2} = zeros(kxx, 1);
        system.A{1} = sparse(ny, ny);
        system.B{1} = sparse(ny, kb);
        system.E{1} = sparse(ny, ne);
        system.N{1} = [ ];
        system.A{2} = sparse(kxx, kxx);
        system.B{2} = sparse(kxx, kxx);
        system.E{2} = sparse(kxx, ne);
        system.N{2} = zeros(kxx, sum(this.Equation.IxHash));
        this.LastSystem.System = system;
    end
end
