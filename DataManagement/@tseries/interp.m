function this = interp(this, varargin)
% interp  Interpolate missing observations
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
% * `Range` [ numeric | char ] - Date range within which any missing
% observations (`NaN`) will be interpolated using observations available
% within that range.
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
% * `Method='Cubic'` [ char | `'Cubic'` ] - Any valid method accepted by the
% built-in `interp1( )` function.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if isempty(this)
    return
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.interp');
    inputParser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    inputParser.addOptionalRangeStartEnd( );
    inputParser.addParameter('Method', 'pchip', @(x) ischar(x) || isa(x, 'string'));
end
inputParser.parse(this, varargin{:});
opt = inputParser.Options;

%--------------------------------------------------------------------------

[data, actualStart] = getDataFromTo(this, opt.SerialOfStart, opt.SerialOfEnd);

if isempty(data)
    this = this.empty(this);
    return
end

sizeOfData = size(data);
numOfPeriods = sizeOfData(1);
numOfColumns = prod( sizeOfData(2:end) );
grid = transpose(1 : numOfPeriods);
for i = 1 : numOfColumns
    inxOfData = ~isnan(data(:, i));
    if any(~inxOfData)
        func = griddedInterpolant(grid(inxOfData), data(inxOfData, i), opt.Method);
        data(~inxOfData, i) = func(grid(~inxOfData));
    end
end

this = fill(this, data, actualStart);

end%
