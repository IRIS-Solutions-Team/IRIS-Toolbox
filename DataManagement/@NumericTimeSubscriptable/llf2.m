function varargout = llf2(varargin)
% llf2  Swap output arguments of the local linear trend filter with tunes.
%
% See help on [`llf`](#llf).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% BWF2, HPF2, LLF2

%--------------------------------------------------------------------------

n = max(2, nargout);
[varargout{1:n}] = llf(varargin{:});
varargout([1, 2]) = varargout([2, 1]); %#ok<VARARG>

end%

