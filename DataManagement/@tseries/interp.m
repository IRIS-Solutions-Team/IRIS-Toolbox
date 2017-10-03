function this = interp(this, varargin)
% interp  Interpolate missing observations.
%
% __Syntax__
%
%     X = interp(X, Range, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series.
%
% * `Range` [ numeric | char ] - Date range on which any missing
% observations (`NaN`) will be interpolated.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Tseries object with the missing observations
% interpolated.
%
%
% __Options__
%
% * `'Method='` [ char | *`'cubic'`* ] - Any valid method accepted by the
% built-in `interp1` function.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isempty(varargin) && DateWrapper.validateDateInput(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
    if ischar(range)
        range = textinp2dat(range);
    end
else
    range = Inf;
end

opt = passvalopt('tseries.interp', varargin{:});

if isempty(this)
    return
end

%--------------------------------------------------------------------------

if isequal(range, Inf)
    range = get(this, 'range');
elseif ~isempty(range)
    range = range(1) : range(end);
    this.Data = rangedata(this, range);
    this.Start = range(1);
else
    this = this.empty(this);
    return
end

data = this.Data(:, :);
grid = dat2dec(range, 'centre');
grid = grid - grid(1);
for i = 1 : size(data, 2)
    indexOfData = ~isnan(data(:, i));
    if any(~indexOfData)
        func = griddedInterpolant(grid(indexOfData), data(indexOfData), opt.method);
        data(~indexOfData, i) = func(grid(~indexOfData));
    end
end
this.Data(:, :) = data;

end
