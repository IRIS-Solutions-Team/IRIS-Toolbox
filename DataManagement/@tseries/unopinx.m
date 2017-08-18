function [x, pos] = unopinx(func, this, dim, varargin)
% unopinx  Unary operators and functions on tseries objects with index returned.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'TIME_SERIES_CONSTRUCTOR');

%--------------------------------------------------------------------------

[x, inx] = unop(func, this, dim, varargin{:});

if dim==1
    pos = this.Start + pos - 1;
else
    pos = TIME_SERIES_CONSTRUCTOR(this.Start, pos);
end

end
