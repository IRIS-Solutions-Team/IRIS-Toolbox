function varargout = subsasgn(this,varargin)
% subsasgn  [Not a public function] Subscripted assignment for namedmat objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = subsasgn(double(this),varargin{:});

end
