function flag = testCompatible(v1, v2)
% testCompatible  True if two vAR objects can occur together on the LHS and RHS in an assignment
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    flag = testCompatible@BaseVAR(v1, v2) ...
        && isequal(class(v1), class(v2)) ...
        && v1.NHyper==v2.NHyper;
catch %#ok<CTCH>
    flag = false;
end

end
