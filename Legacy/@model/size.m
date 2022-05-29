function varargout = size(this)
% size  Number of alternative parameterisations in model object
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
    
%--------------------------------------------------------------------------

if nargout<=1
    varargout = { [1, length(this)] };
else
    varargout = {1, length(this)};
end
    
end
