function varargout = size(this)
% size  Number of alternative parameterisations in model object
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
    
%--------------------------------------------------------------------------

if nargout<=1
    varargout = { [1, length(this)] };
else
    varargout = {1, length(this)};
end
    
end
