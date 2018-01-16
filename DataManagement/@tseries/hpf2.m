function varargout = hpf2(varargin)
% hpf2  Swap output arguments of the Hodrick-Prescott filter with tunes.
%
% See help on [`hpf`](#hpf).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% BWF2, HPF2, LLF2

%--------------------------------------------------------------------------

n = max(2,nargout);
[varargout{1:n}] = hpf(varargin{:});
varargout([1,2]) = varargout([2,1]); %#ok<VARARG>

end

