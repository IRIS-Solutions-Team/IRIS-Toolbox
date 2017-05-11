function flag = isCompatible(q1, q2)
% iscompatible  True if two model.Quantity objects are compatible.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

flag = isequal(q1.Name, q2.Name) && isequal(q1.Type, q2.Type);

end
