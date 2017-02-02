function this = fill(this, qty, lsEqn, ixEqn)
% fill  Fill in incidence matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int32;

%--------------------------------------------------------------------------

t0 = PTR(find(this.Shift==0)); %#ok<FNDSB>
nsh = length(this.Shift);
nEqn = length(lsEqn);
nQty = length(qty.Name);

[epsCurrent, epsShifted] = model.Incidence.getIncidenceEps(lsEqn, ixEqn);

ind = sub2ind([nEqn, nQty, nsh], ...
    epsCurrent(1, :), epsCurrent(2, :), t0+epsCurrent(3, :));
this.Matrix(ind) = true;

ind = sub2ind([nEqn, nQty, nsh], ...
    epsShifted(1, :), epsShifted(2, :), t0+epsShifted(3, :));
this.Matrix(ind) = true;

end
