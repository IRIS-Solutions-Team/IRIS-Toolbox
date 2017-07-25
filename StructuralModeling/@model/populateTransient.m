function this = populateTransient(this)
% populateTransient  Recreate transient properties in model object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nQuan = length(this.Quantity.Name);
%nEqtn = length(this.Equation.Input);
%quanType = this.Quantity.Type;
ny = sum(this.Quantity.Type==TYPE(1));
nx = sum(this.Quantity.Type==TYPE(2));
ne = sum(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));
% ixp = this.Quantity.Type==TYPE(4);
%posp = find(ixp);
nyxe = ny + nx + ne;

% Reset handle object to last system info.
resetLastSystem( );

return




    function resetLastSystem( )
        % Reset LastSystem to a new model.LastSystem handle object.
        this.LastSystem = model.LastSystem( );
        
        % Parameters and steady states
        %------------------------------
        this.LastSystem.Quantity = nan(1, nQuan);
        
        % Derivatives
        %-------------
        nsh = nofShift(this.Incidence.Dynamic);
        nDeriv = nsh*nyxe;
        nEqtn12 = sum(this.Equation.Type<=2);
        deriv = struct( );
        deriv.c = zeros(nEqtn12, 1);
        deriv.f = sparse(nEqtn12, nDeriv);
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
