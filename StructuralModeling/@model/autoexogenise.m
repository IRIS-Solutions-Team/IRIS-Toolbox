function varargout = autoexogenise(this, varargin)
% autoexogenise  Obsolete function; use autoexog instead.
%
% Obsolete IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = autoexog(this, varargin{:});

if isempty(varargin)
    varargout{1} = varargout{1}.Dynamic;
end

end
