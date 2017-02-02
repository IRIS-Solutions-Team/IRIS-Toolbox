function [This,TT,TS] = trend(This,varargin)
% trend  Estimate a time trend.
%
% Syntax
% =======
%
%     X = trend(X,range)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `Range` [ numeric | `@all` | char ] - Range for which the trend will be
% computed; `@all` means the entire range of the input times series.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output trend time series.
%
% Options
% ========
%
% * `'break='` [ numeric | *empty* ] - Vector of breaking points at which
% the trend may change its slope.
%
% * `'connect='` [ *`true`* | `false` ] - Calculate the trend by connecting
% the first and the last observations.
%
% * `'diff='` [ `true` | *`false`* ] - Estimate the trend on differenced
% data.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the input data,
% de-logarithmise the output data.
%
% * `'season='` [ `true` | *`false`* | `2` | `4` | `6` | `12` ] - Include
% deterministic seasonal factors in the trend.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isempty(varargin) && isdatinp(varargin{1})
    Range = varargin{1};
    varargin(1) = [ ];
    if ischar(Range)
        Range = textinp2dat(Range);
    end
else
    Range = @all;
end

% Parse options.
opt = passvalopt('tseries.trend',varargin{:});

%--------------------------------------------------------------------------

[ThisData,Range] = rangedata(This,Range);
tmpSize = size(ThisData);
ThisData = ThisData(:,:);

% Compute the trend.
[ThisData,TTdata,TSdata] = tseries.mytrend(ThisData,Range(1),opt);
ThisData = reshape(ThisData,tmpSize);

% Output data.
This = replace(This,ThisData,Range(1));
This = trim(This);
if nargout > 1
    TT = replace(This,reshape(TTdata,tmpSize));
    TT = trim(TT);
    if nargout > 2
        TS = replace(This,reshape(TSdata,tmpSize));
        TS = trim(TS);
    end
end

end
