function varargout = bwf2(varargin)
% bwf  Swap output arguments of the Butterworth filter with tunes.
%
% See help on [`tseries/bwf`](tseries/bwf).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

% BWF2, HPF2, LLF2

%--------------------------------------------------------------------------

n = max(2,nargout);
[varargout{1:n}] = bwf(varargin{:});
varargout([1,2]) = varargout([2,1]); %#ok<VARARG>

end
