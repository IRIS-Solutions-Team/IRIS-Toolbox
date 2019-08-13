function this = grow(this, growth, dates, varargin)
% grow  Grow time series at specified growth rates
%{
% ## Syntax ##
%
%     x = grow(x, growth, dates, ...)
%
%
% ## Input arguments ##
%
% **`x`** [ Series ] - 
% Input time series including at least the initial condition for the level.
%
% **`growth`** [ Series | numeric ] - 
% Time series or numeric scalar specifying the growth rates at `dates`.
%
% **`dates`** [ DateWrapper ] - 
% Date range or a vector of dates on which the level series will be
% extended by its growth rates.
%
%
% ## Output Arguments ##
%
% **`x`** [ Series ] - 
% Output time series constructed from the input time series, `x`, extended by
% its growth rates, `growth`.
%
%
% ## Options ##
%
% **`BaseShift=-1`** [ numeric ] -
% Negative number specifying the lag of the base period to which the growth
% rates apply.
%
% **`Percent=true`** [ `true` | `false` ] -
% Indicate whether the growth time series, `growth`, is specified as
% percents or decimal numbers.
%
% **`RateOfChange='Net'` [ `'Gross'` | `'Net'` ] -
% Indicate whether the growth time series, `growth`, is specified as net
% rates of change or gross rates of change.
%
%
% ## Description ##
%
% The function `grow(~)` calculates new values at `dates` (which may not
% constitute a continuous range, and be discrete time periods instead)
% using the following formula:
%
% $$ x_t = g_t \cdot x_{t-k} $$
%
% where $$ k $$ is a time lag specified by the option `BaseShift=`, and the
% values $$ g_t $$ are determined from the input series `growth` by
%
% * dividing them by 100 if `Percent=true`
% * adding 1 if `RateOfChange='Net'`
%
% Any values contained in the input series `x` outside the `dates` are
% preserved in the output series unchanged.
%
%
% ## Example ##
%
% Extend a quarterly series `x` using gross rates of growth `g` (expressed
% so that `1.05` means a 5% rage of change) from 2020Q1 to 2030Q4:
%
%     >> x = grow( x, g, qq(2020,1):qq(2030,4), ...
%                  'Percent=', false, ...
%                  'RateOfChange=', 'Gross' )
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.grow');
    addRequired(parser, 'x', @(x) isa(x, 'NumericTimeSubscriptable'));
    addRequired(parser, 'growth', @(x) isa(x, 'NumericTimeSubscriptable') || validate.numericScalar(x));
    addRequired(parser, 'dates', @DateWrapper.validateProperDateInput);
    addParameter(parser, 'BaseShift', -1, @(x) validate.numericScalar(x) && x==round(x) && x<0);
    addParameter(parser, 'Percent', true, @validate.logicalScalar);
    addParameter(parser, 'RateOfChange', 'Net', @(x) any(strcmpi(x, {'Net', 'Gross'})));
end%
parse(parser, this, growth, dates, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

lag = -opt.BaseShift;
dates = double(dates);
minDate = min(dates);
maxDate = max(dates);
startOfX = this.StartAsNumeric;
endOfX = this.EndAsNumeric;
startOfAll = min(minDate-lag, startOfX);
endOfAll = max(maxDate, endOfX+lag);
extendedRange = startOfAll : endOfAll;

% Get level data
xData = getData(this, extendedRange);
sizeOfX = size(xData);
xData = xData(:, :);

% Get growth rate data
if isa(growth, 'NumericTimeSubscriptable')
    growthData = getData(growth, extendedRange);
    growthData = growthData(:, :);
else
    growthData = repmat(growth, size(xData));
end

if opt.Percent
    growthData = growthData / 100;
end

if strcmpi(opt.RateOfChange, 'Net')
    growthData = growthData + 1;
end


% /////////////////////////////////////////////////////////////////////////
posOfDates = round(dates - startOfAll + 1);
for t = transpose(posOfDates(:))
    xData(t, :) = xData(t-lag, :) .* growthData(t, :);
end
% /////////////////////////////////////////////////////////////////////////


% Reshape output data back
if numel(sizeOfX)>2
    xData = reshape(xData, [size(xData, 1), sizeOfX(2:end)]);
end

% Update output series
this = fill(this, xData, extendedRange(1));

end%

