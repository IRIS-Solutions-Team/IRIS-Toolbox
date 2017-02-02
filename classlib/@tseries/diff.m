function X = diff(X,K)
% diff  First difference.
%
% Syntax
% =======
%
%     X = diff(X)
%     X = diff(X,K)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% * `K` [ numeric ] - Number of periods over which the first difference
% will be computed; `Y = X - X{K}`. Note that `K` must be a negative number
% for the usual backward differencing. If not specified, `K` will be set to
% `-1`.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - First difference of the input data.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% diff, df, pct, apct

try
    K; %#ok<VUNUS>
catch %#ok<CTCH>
    K = -1;
end

pp = inputParser( );
pp.addRequired('K',@isnumericscalar);
pp.parse(K);

%--------------------------------------------------------------------------

% @@@@@ MOSW
X = unop(@(varargin) tseries.mydiff(varargin{:}),X,0,K);

end
