function this = subsalt(this, ixLhs, obj, ixRhs)
% subsalt  Implement subscripted reference and assignment for varobj objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin==2
    % Subscripted reference This(Lhs).
    this.A = this.A(:, :, ixLhs);
    this.Omega = this.Omega(:, :, ixLhs);
    this.EigVal = this.EigVal(1, :, ixLhs);
    this.IxFitted = this.IxFitted(1, :, ixLhs);
elseif nargin==3 && isempty(obj)
    % Empty subscripted assignment This(Lhs) = empty.
    this.A(:, :, ixLhs) = [ ];
    this.Omega(:, :, ixLhs) = [ ];
    this.EigVal(:, :, ixLhs) = [ ];
    this.IxFitted(:, :, ixLhs) = [ ];
elseif nargin==4 && mycompatible(this, obj)
    try
        this.A(:, :, ixLhs) = obj.A(:, :, ixRhs);
        this.Omega(:, :, ixLhs) = obj.Omega(:, :, ixRhs);
        this.EigVal(:, :, ixLhs) = obj.EigVal(:, :, ixRhs);
        this.IxFitted(:, :, ixLhs) = obj.IxFitted(:, :, ixRhs);
    catch %#ok<CTCH>
        utils.error('varobj:subsalt', ...
            ['Subscripted assignment failed, ', ...
            'LHS and RHS objects are incompatible.']);
    end
else
    throw( exception.Base('General:INVALID_REFERENCE', 'error'), class(this) );
end

end
