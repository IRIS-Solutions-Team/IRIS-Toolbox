function Flag = mycompatible(V1,V2)
% mycompatible  [Not a public function] True if two SVAR objects can occur together on the LHS and RHS in an assignment.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    Flag = isequal(class(V1),class(V2)) ...
        && mycompatible@VAR(V1,V2);
catch
    Flag = false;
    
end
