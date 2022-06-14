function [x, varargout] = unopinx(func, this, dim, varargin)
% unopinx  Unary operators and functions on tseries objects with index returned
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

[x, pos] = unop(func, this, dim, varargin{:});

if dim==1
    if pos==1
        pos = this.Start;
    else
        pos = round(this.Start + (pos - 1));
    end
    varargout{1} = pos;
else
    varargout{1} = fill(this, pos, this.Start, '', [ ]);
end

end%

