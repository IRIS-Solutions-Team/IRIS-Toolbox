function [this, epsCurrent, epsShifted] = fill(this, qty, lsEqn, ixEqn, varargin)
% fill  Fill in incidence matrices
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

PTR = @int32;

%--------------------------------------------------------------------------

t0 = PTR(find(this.Shift==0)); %#ok<FNDSB>
numShifts = length(this.Shift);
numEquations = length(lsEqn);
numQuantities = length(qty.Name);

% Reset incidence in indexEquations
this.Matrix(ixEqn, :) = false;

% Get equation, position of name, shift
[epsCurrent, epsShifted] = ...
    model.component.Incidence.getIncidenceEps(lsEqn, ixEqn, varargin{:});

ind = sub2ind([numEquations, numQuantities, numShifts], ...
    epsCurrent(1, :), epsCurrent(2, :), t0+epsCurrent(3, :));
this.Matrix(ind) = true;

ind = sub2ind([numEquations, numQuantities, numShifts], ...
    epsShifted(1, :), epsShifted(2, :), t0+epsShifted(3, :));
this.Matrix(ind) = true;

end
