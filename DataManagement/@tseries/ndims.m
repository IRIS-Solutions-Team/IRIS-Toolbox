function N = ndims(This,varargin)
% ndims  Number of dimensions in tseries object data.
%
% Syntax
% =======
%
%     N = ndims(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of dimensions in the input object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

N = ndims(This.data,varargin{:});

end