function flag = mycompatible(v1, v2)
% mycompatible  True if two vAR objects can occur together on the LHS and RHS in an assignment
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    flag = mycompatible@varobj(v1, v2) ...
        && isequal(class(v1), class(v2)) ...
        && v1.NHyper==v2.NHyper;
catch %#ok<CTCH>
    flag = false;
end

end
