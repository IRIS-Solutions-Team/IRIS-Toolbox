function flag = testCompatible(q1, q2)
% testCompatible  True if two model.Quantity objects are compatible.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

flag = isequal(q1.Name, q2.Name) && isequal(q1.Type, q2.Type);

end
