function this = subsalt(this, ixlhs, obj, ixRhs)
% subsalt  Implement subscripted reference and assignment for VAR objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin==2
    % Subscripted reference this(lhs).
    this = subsalt@BaseVAR(this, ixlhs);
    this.K = this.K(:, :, ixlhs);
    this.J = this.J(:, :, ixlhs);
    this.G = this.G(:, :, ixlhs);
    this.AIC = this.AIC(1, ixlhs);
    this.AICc = this.AICc(1, ixlhs);
    this.SBC = this.SBC(1, ixlhs);
    this.T = this.T(:, :, ixlhs);
    this.U = this.U(:, :, ixlhs);
    this.X0 = this.X0(:, :, ixlhs);
    this.Sigma = this.Sigma(:, :, ixlhs);
elseif nargin==3 && isempty(obj)
    % Empty subscripted assignment this(lhs) = empty.
    this = subsalt@BaseVAR(this, ixlhs, obj);
    this.K(:, :, ixlhs) = [ ];
    this.J(:, :, ixlhs) = [ ];
    this.G(:, :, ixlhs) = [ ];
    this.AIC(:, ixlhs) = [ ];
    this.AICc(:, ixlhs) = [ ];
    this.SBC(:, ixlhs) = [ ];
    this.T(:, :, ixlhs) = [ ];
    this.U(:, :, ixlhs) = [ ];
    this.X0(:, :, ixlhs) = [ ];
    this.Sigma(:, :, ixlhs) = [ ];
elseif nargin==4 && testCompatible(this, obj)
    % Proper subscripted assignment this(lhs) = Obj(Rhs).
    this = subsalt@BaseVAR(this, ixlhs, obj, ixRhs);
    try
        this.K(:, :, ixlhs) = obj.K(:, :, ixRhs);
        this.J(:, :, ixlhs) = obj.J(:, :, ixRhs);
        this.G(:, :, ixlhs) = obj.G(:, :, ixRhs);
        this.AIC(:, ixlhs) = obj.AIC(:, ixRhs);
        this.AICc(:, ixlhs) = obj.AICc(:, ixRhs);
        this.SBC(:, ixlhs) = obj.SBC(:, ixRhs);
        this.T(:, :, ixlhs) = obj.T(:, :, ixRhs);
        this.U(:, :, ixlhs) = obj.U(:, :, ixRhs);
        this.X0(:, :, ixlhs) = obj.X0(:, :, ixRhs);
        this.Sigma(:, :, ixlhs) = obj.Sigma(:, :, ixRhs);
    catch %#ok<CTCH>
        utils.error('VAR:subsalt', ...
            ['Subscripted assignment to %s object failed, ', ...
            'LHS and RHS objects are incompatible.'], ...
            class(this));
    end
else
    throw( exception.Base('General:INVALID_REFERENCE', 'error'), 'VAR' );
end

end%

