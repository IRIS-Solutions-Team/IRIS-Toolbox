function [X,Inx] = unopinx(Func,This,Dim,varargin)
% unopinx  [Not a public function] Unary operators and functions on tseries objects with index returned.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[X,Inx] = unop(Func,This,Dim,varargin{:});

if Dim == 1
    Inx = This.start + Inx - 1;
else
    Inx = tseries(This.start,Inx);
end

end
