function This = expsmooth(This,Beta,Range,varargin)
% ews  Exponential smoothing.
%
% Syntax
% =======
%
%     X = expsmooth(X,Beta,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `Beta` [ numeric ] - Exponential factor.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Exponentially smoothed series.
%
%
% Options
% ========
%
% * `'init='` [ numeric | *`NaN`* ] - Add this value before the first
% observation to initialise the smoothing.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the data before
% filtering, de-logarithmise afterwards.
%
% Description
% ============
%
% Examples
% =========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    Range; %#ok<VUNUS>
catch
    Range = Inf;
end

opt = passvalopt('tseries.expsmooth',varargin{:});

%--------------------------------------------------------------------------

This = resize(This,Range);

if opt.log
    This.data = log(This.data);
end

This.data = tseries.myexpsmooth(This.data,Beta,opt.init);

if opt.log
    This.data = exp(This.data);
end

This = trim(This);

end