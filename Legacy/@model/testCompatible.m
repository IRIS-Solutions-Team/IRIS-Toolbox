function flag = testCompatible(m1, m2)
% testCompatible  True if two models can occur together on the LHS and RHS in an assignment.
%
% Syntax
% =======
%
%     Flag = testCompatible(M1,M2)
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    flag = isa(m1, 'model') && isa(m2, 'model') ...
        && testCompatible(m1.Quantity, m2.Quantity) ...
        && testCompatible(m1.Equation, m2.Equation) ...
        && testCompatible(m1.Incidence.Dynamic, m2.Incidence.Dynamic) ...
        && testCompatible(m1.Incidence.Steady, m2.Incidence.Steady) ...
        && testCompatible(m1.Vector, m2.Vector);
catch %#ok<CTCH>
    flag = false;
end

end
