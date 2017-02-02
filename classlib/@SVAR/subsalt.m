function this = subsalt(this, ixLhs, obj, ixRhs)
% subsalt  Implement subscripted reference and assignment for SVAR objects with multiple parameterizations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    % Subscripted reference This(Lhs).
    this = subsalt@VAR(this, ixLhs);
    this.B = this.B(:, :, ixLhs);
    this.Std = this.Std(:, ixLhs);
    this.Method = this.Method(1, ixLhs);
elseif nargin == 3 && isempty(obj)
    % Empty subscripted assignment This(Lhs) = empty.
    this = subsalt@VAR(this, ixLhs, [ ]);
    this.B(:, :, ixLhs) = [ ];
    this.Std(:, ixLhs) = [ ];
    this.Method(1, ixLhs) = [ ];
elseif nargin == 4 && mycompatible(this, obj)
    % Proper subscripted assignment This(Lhs) = Obj(Rhs).
    this = subsalt@VAR(this, ixLhs, obj, ixRhs);
    try
        this.B(:, :, ixLhs) = obj.B(:, :, ixRhs);
        this.Std(:, ixLhs) = obj.Std(:, ixRhs);
        this.Method(1, ixLhs) = obj.Method(1, ixRhs);
    catch %#ok<CTCH>
        utils.error('SVAR:subsalt', ...
            ['Subscripted assignment to %s object failed, ', ...
            'LHS and RHS objects are incompatible.'], ...
            class(this));
    end
else
    throw( exception.Base('General:INVALID_REFERENCE', 'error'), 'SVAR' );
end

end
