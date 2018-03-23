function this = round(this, varargin)
% round  Round tseries values to specified number of decimals.
%
% Syntax
% =======
%
%     X = round(X)
%     X = round(X, Dec)
%     X = round(X, Dec, 'significant')
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object whose data will be rounded.
%
% * `Dec` [ numeric ] - Number of decimals to which the tseries data will
% be rounded; if not specified, the data are rounded to nearest integer.
%
% * `'significant'` - See documentation on the built-in Matlab function
% `round`; works only in R2014b or later.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Rounded tseries object.
%
%
% Description
% ============
%
% The number of decimals, to which the tseries data will be rounded, can be
% positive, zero, or negative.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

try %#ok<TRYNC>
    this.data = round(this.data, varargin{:});
    return
end

try
    dec = varargin{1};
catch %#ok<CTCH>
    dec = 0;
end

%--------------------------------------------------------------------------

if dec~=0
    factor = 10^dec;
    this.data = this.data * factor;
end
this.data = round(this.data);
if dec~=0
    this.data = this.data / factor;
end

end
