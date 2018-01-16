function varargout = size(This,varargin)
% size  Size of tseries object data.
%
% Syntax
% =======
%
%     S = size(X)
%     [S1,S2,...,Sn] = size(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object whose size will be returned.
%
% Output arguments
% =================
%
% * `S` [ numeric ] - Vector of sizes of the tseries object data in each
% dimension, `S = [S1,S2,...,Sn]`.
%
% * `S1`, `S2`, ..., `Sn` [ numeric ] - Sizes of the tseries object data in
% each dimension.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = size(This.data,varargin{:});

end