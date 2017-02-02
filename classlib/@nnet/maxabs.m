
% maxabs  [Not a public function]
%
% Can produce misleading results. Designed only to be used by
% nnet/estimate( ).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

function X = maxabs(A,B)
X = Inf ;
Ap = [get(A,'activation'); get(A,'hyper'); get(A,'output')] ;
Bp = [get(B,'activation'); get(B,'hyper'); get(B,'output')] ;
try
    X = max(abs(Ap-Bp)) ;
end
end