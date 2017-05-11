function Y = myeval(This,Time,LhsTs,LhsInpName,LhsStamp)
% myeval  [Not a public function] Return tseries value when evaluating time-recursive expressions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% A tsydney object can be either a plain tseries or a tseries function
% whose evaluation involves observations (lags, leads) other than the
% current observation (such as `diff`, `pct`, etc).
func = This.Func;
funcArgs = { };
if ~isempty(func)
    funcArgs = This.args(2:end);
    This = This.args{1};
end

% Get the RHS tseries object.
rhsTs = This.args;

% Check if `This` is the same tseries object as `Lhs`. Test two conditions:
% * the time stamp;
% * the input name.
% The test fails (false positive) in the following case
%
%     d.y = d.x;
%     d.x(t) = 0.8*d.y(t-1)
%
% behaves as if
%
%     d.x(t) = 0.8*d.x(t-1)
%
% This happens only if two tseries with an identical stamp are stored in
% dbase (struct) or cell array (in which case `inputname(...)` returns an
% empty string).
%
% A workaround is to use any subscripted reference or operator/function on
% one of the series (to change the time stamp), apart from a plain
% assignment, e.g.
%
%     d.y = d.x{:};
%     d.y = 1*d.x;
%
rhsStamp = rhsTs.Stamp;
rhsInpName = This.InpName;
if isequal(rhsStamp,LhsStamp) && isequal(rhsInpName,LhsInpName)
    rhsTs = LhsTs;
end

sh = This.TRec.Shift;
if ~isempty(func)
    rhsTs = feval(func,rhsTs,funcArgs{:});
end

Y = rangedata(rhsTs,Time+sh);
if ~isempty(This.Ref)
    Y = Y(:,This.Ref{:});
end

end
