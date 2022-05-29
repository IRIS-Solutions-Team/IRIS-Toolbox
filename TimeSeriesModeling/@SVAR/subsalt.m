function this = subsalt(this, ixLhs, obj, ixRhs)
% subsalt  Implement subscripted reference and assignment for SVAR objects with multiple parameterizations
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin==2
    % Subscripted reference This(Lhs)
    this = subsalt@VAR(this, ixLhs);
    this.A0 = this.A0(:, :, ixLhs);
    this.B0 = this.B0(:, :, ixLhs);
    this.B = this.B(:, :, ixLhs);
    this.Std = this.Std(:, ixLhs);
    this.Rank = this.Rank(:, ixLhs);
    this.Method = this.Method(:, ixLhs);
elseif nargin==3 && isempty(obj)
    % Empty subscripted assignment This(Lhs) = empty
    this = subsalt@VAR(this, ixLhs, [ ]);
    this.A0(:, :, ixLhs) = [ ];
    this.B0(:, :, ixLhs) = [ ];
    this.B(:, :, ixLhs) = [ ];
    this.Std(:, ixLhs) = [ ];
    this.Std(:, ixLhs) = [ ];
    this.Rank(:, ixLhs) = [ ];
    this.Method(:, ixLhs) = [ ];
elseif nargin==4 && testCompatible(this, obj)
    % Proper subscripted assignment This(Lhs) = Obj(Rhs)
    this = subsalt@VAR(this, ixLhs, obj, ixRhs);
    try
        this.A0(:, :, ixLhs) = obj.A0(:, :, ixRhs);
        this.B0(:, :, ixLhs) = obj.B0(:, :, ixRhs);
        this.B(:, :, ixLhs) = obj.B(:, :, ixRhs);
        this.Std(:, ixLhs) = obj.Std(:, ixRhs);
        this.Rank(:, ixLhs) = obj.Rank(:, ixRhs);
        this.Method(:, ixLhs) = obj.Method(:, ixRhs);
    catch %#ok<CTCH>
        utils.error('SVAR:subsalt', ...
            ['Subscripted assignment to %s object failed, ', ...
            'LHS and RHS objects are incompatible.'], ...
            class(this));
    end
else
    throw( exception.Base('General:INVALID_REFERENCE', 'error'), 'SVAR' );
end

end%

