% Type `web Series/hpf.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function varargout = hpf(varargin)

order = 2;
[varargout{1:nargout}] = implementFilter(order, varargin{:});

end%

