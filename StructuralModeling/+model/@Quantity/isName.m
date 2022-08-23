function varargout = isName(this, varargin)
% isName  True for valid names in model.Quantity object.
% 
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = length(varargin);
varargout = cell(1, n);
for i = 1 : n
    varargout{i} = any( strcmp(this.Name, varargin{i}) );
end

end
