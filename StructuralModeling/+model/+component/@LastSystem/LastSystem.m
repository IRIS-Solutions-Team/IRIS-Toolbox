% LastSystem  Handle to last system matrices.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

classdef LastSystem < handle
    properties
        Values = double.empty(1, 0)
        Deriv = struct([ ])
        System = struct([ ])
    end
end
