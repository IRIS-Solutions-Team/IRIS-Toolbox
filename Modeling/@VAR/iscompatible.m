function Flag = iscompatible(V1,V2)
% iscompatible  True if two VAR objects can occur together on the LHS and RHS in an assignment.
%
% Syntax
% =======
%
%     Flag = iscompatible(V1,V2)
%
% Input arguments
% ================
%
% * `V1`, `V2` [ model ] - Two VAR objects that will be tested for
% compatibility.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if `V1` and `V2` can occur in an
% assignment, `V1(...) = V2(...)`, or horizonatl concatenation, `[V1,V2]`.
%
% Description
% ============
%
% The function compares the names of all variables, shocks, and parameters,
% and the composition of the state-space vectors and matrices.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = mycompatible(V1,V2);

end