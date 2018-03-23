function flag = iscompatible(m1, m2)
% iscompatible  True if two models can occur together on the LHS and RHS in an assignment.
%
% Syntax
% =======
%
%     Flag = iscompatible(M1,M2)
%
%
% Input arguments
% ================
%
%
% * `M1`, `M2` [ model ] - Two model objects that will be tested for
% compatibility.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if `M1` and `M1` can occur in an
% assignment, `M1(...) = M2(...)` or horziontal concatenation, `[M1,M2]`.
%
%
% Description
% ============
%
% The function compares the names of all variables, shocks, and parameters,
% and the composition of the state-space vectors.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    flag = isa(m1, 'model') && isa(m2, 'model') ...
        && isCompatible(m1.Quantity, m2.Quantity) ...
        && isCompatible(m1.Equation, m2.Equation) ...
        && isCompatible(m1.Incidence.Dynamic, m2.Incidence.Dynamic) ...
        && isCompatible(m1.Incidence.Steady, m2.Incidence.Steady) ...
        && isCompatible(m1.Vector, m2.Vector);
catch %#ok<CTCH>
    flag = false;
end

end
