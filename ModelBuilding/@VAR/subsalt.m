function this = subsalt(this, ixLhs, obj, ixRhs)
% subsalt  Implement subscripted reference and assignment for VAR objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin==2
    % Subscripted reference This(Lhs).
    this = subsalt@varobj(this, ixLhs);
    this.K = this.K(:, :, ixLhs);
    this.J = this.J(:, :, ixLhs);
    this.G = this.G(:, :, ixLhs);
    this.Aic = this.Aic(1, ixLhs);
    this.Sbc = this.Sbc(1, ixLhs);
    this.T = this.T(:, :, ixLhs);
    this.U = this.U(:, :, ixLhs);
    this.X0 = this.X0(:, :, ixLhs);
    if ~isempty(this.Sigma)
        this.Sigma = this.Sigma(:, :, ixLhs);
    end
elseif nargin==3 && isempty(obj)
    % Empty subscripted assignment This(Lhs) = empty.
    this = subsalt@varobj(this, ixLhs, obj);
    this.K(:, :, ixLhs) = [ ];
    this.J(:, :, ixLhs) = [ ];
    this.G(:, :, ixLhs) = [ ];
    this.Aic(:, ixLhs) = [ ];
    this.Sbc(:, ixLhs) = [ ];
    this.T(:, :, ixLhs) = [ ];
    this.U(:, :, ixLhs) = [ ];
    this.X0(:, :, ixLhs) = [ ];
    if ~isempty(this.Sigma) && ~isempty(x.Sigma)
        this.Sigma(:, :, ixLhs) = [ ];
    end
elseif nargin==4 && mycompatible(this, obj)
    % Proper subscripted assignment This(Lhs) = Obj(Rhs).
    this = subsalt@varobj(this, ixLhs, obj, ixRhs);
    try
        this.K(:, :, ixLhs) = obj.K(:, :, ixRhs);
        this.J(:, :, ixLhs) = obj.J(:, :, ixRhs);
        this.G(:, :, ixLhs) = obj.G(:, :, ixRhs);
        this.Aic(:, ixLhs) = obj.Aic(:, ixRhs);
        this.Sbc(:, ixLhs) = obj.Sbc(:, ixRhs);
        this.T(:, :, ixLhs) = obj.T(:, :, ixRhs);
        this.U(:, :, ixLhs) = obj.U(:, :, ixRhs);
        this.X0(:, :, ixLhs) = obj.X0(:, :, ixRhs);
        if ~isempty(this.Sigma) && ~isempty(obj.Sigma)
            this.Sigma(:, :, ixLhs) = obj.Sigma(:, :, ixRhs);
        end
    catch %#ok<CTCH>
        utils.error('VAR:subsalt', ...
            ['Subscripted assignment to %s object failed, ', ...
            'LHS and RHS objects are incompatible.'], ...
            class(this));
    end
else
    throw( exception.Base('General:INVALID_REFERENCE', 'error'), 'VAR' );
end

end
