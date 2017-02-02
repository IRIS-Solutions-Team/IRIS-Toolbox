function This = plus(This,K)
% plus  Create time-recursive lead of tseries object.
%
% Syntax
% =======
%
%     X{T+K}
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object whose time-recursive lead will be
% created.
%
% * `T` [ trec ] - Initialized trec object.
%
% * `K` [ numeric ] - Integer scalar specifying the lead.
%
% Description
% ============
%
% The tseries object, `X`, referenced by `T+K` in a time-recursive
% expression will, in each iteration, return a value that corresponds to
% period `t+K`, where `t` is the currently processed date from the vector
% of dates (or date range) associated with the trec object, `T`.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------

This.Shift = This.Shift + K;

end
