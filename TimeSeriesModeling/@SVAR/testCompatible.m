function flag = testCompatible(V1, V2)
% testCompatible  [Not a public function] True if two SVAR objects can occur together on the LHS and RHS in an assignment.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    flag = isequal(class(V1), class(V2)) ...
           && testCompatible@VAR(V1, V2);
catch
    flag = false;
    
end

end%

