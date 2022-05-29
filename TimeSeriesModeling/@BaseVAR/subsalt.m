function this = subsalt(this, ixLhs, obj, ixRhs)
% subsalt  Implement subscripted reference and assignment for BaseVAR derived objects with multiple parameterisations
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

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
elseif nargin==4 && testCompatible(this, obj)
    try
        this.A(:, :, ixLhs) = obj.A(:, :, ixRhs);
        this.Omega(:, :, ixLhs) = obj.Omega(:, :, ixRhs);
        this.EigVal(:, :, ixLhs) = obj.EigVal(:, :, ixRhs);
        this.IxFitted(:, :, ixLhs) = obj.IxFitted(:, :, ixRhs);
    catch %#ok<CTCH>
        exception.error([
            "BaseVAR:SubscriptedAssignmentFailed"
            "Subscripted assignment failed; the LHS and RHS objects "
            "are not compatible with each other. "
        ]);
    end
end

end%

