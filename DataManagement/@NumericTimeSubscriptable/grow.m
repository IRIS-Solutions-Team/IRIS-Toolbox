function this = grow(this, operator, growth, dates, varargin)
% grow  Cumulate time series at specified growth rates or differences
%{
% ## Syntax ##
%
%     x = grow(x, operator, growth, dates, ...)
%
%
% ## Input arguments ##
%
% __`x`__ [ Series ] - 
% Input time series including at least the initial condition for the level.
%
% __`operator`__ [ `*` | `+` | `/` | `-` | function_handle ] - 
% Operator applied to cumulate the time series.
%
% __`growth`__ [ Series | numeric ] - 
% Time series or numeric scalar specifying the growth rates or differences.
%
% __`dates`__ [ DateWrapper ] - 
% Date range or a vector of dates on which the level series will be
% cumulated.
%
%
% ## Output Arguments ##
%
% __`x`__ [ Series ] - 
% Output time series constructed from the input time series, `x`, extended by
% its growth rates or differences, `growth`.
%
%
% ## Options ##
%
% __`BaseShift=-1`__ [ numeric ] -
% Negative number specifying the lag of the base period to which the growth
% rates apply.
%
%
% ## Description ##
%
% The function `grow(~)` calculates new values at `dates` (which may not
% constitute a continuous range, and be discrete time periods instead)
% using one of the the following formulas (depending on the `operator`):
%
% * $$ x_t = x_{t-k} \cdot g_t $$
%
% * $$ x_t = x_{t-k} + g_t $$
%
% * $$ x_t = x_{t-k} / g_t $$
%
% * $$ x_t = x_{t-k} - g_t $$
%
% where $$ k $$ is a time lag specified by the option `BaseShift=`, and the
% values $$ g_t $$ are given by the second input series `growth`.
% Alternatively, the operator applied to $$ x_{t-k} $$ and $$ g_t $$ can be
% any user-specified function.
%
% Any values contained in the input series `x` outside the `dates` are
% preserved in the output series unchanged.
%
%
% ## Example ##
%
% Extend a quarterly series `x` using the gross rates of growth calculated
% from another series, `y`:
%
%     >> x = grow(x, '*', roc(y), qq(2020,1):qq(2030,4));
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable/grow');
    addRequired(parser, 'x', @(x) isa(x, 'NumericTimeSubscriptable'));
    addRequired(parser, 'operator', @(x) validate.anyString(x, '*', '+', '/', '-') || isa(x, 'function_handle'));
    addRequired(parser, 'growth', @(x) isa(x, 'NumericTimeSubscriptable') || validate.numericScalar(x));
    addRequired(parser, 'dates', @DateWrapper.validateProperDateInput);
    addParameter(parser, 'BaseShift', -1, @(x) validate.numericScalar(x) && x==round(x) && x<0);
end
parse(parser, this, operator, growth, dates, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

switch string(operator)
    case "*"
        func = @times;
    case "+"
        func = @plus;
    case "/"
        func = @rdivide;
    case "-"
        func = @minus;
    otherwise
        func = operator;
end

dates = double(dates);
minDate = min(dates);
maxDate = max(dates);
startX = this.StartAsNumeric;
endX = this.EndAsNumeric;
startAll = min(minDate+opt.BaseShift, startX);
endAll = max(maxDate, endX-opt.BaseShift);
extendedRange = startAll : endAll;

% Get level data
xData = getData(this, extendedRange);
sizeX = size(xData);
xData = xData(:, :);

% Get growth rate data
if isa(growth, 'NumericTimeSubscriptable')
    growthData = getData(growth, extendedRange);
    growthData = growthData(:, :);
else
    growthData = repmat(growth, size(xData));
end


% /////////////////////////////////////////////////////////////////////////
posDates = round(dates - startAll + 1);
for t = reshape(posDates, 1, [ ])
    xData(t, :) = func(xData(t+opt.BaseShift, :), growthData(t, :));
end
% /////////////////////////////////////////////////////////////////////////

hereCheckMissingObs( );

% Reshape output data back
if numel(sizeX)>2
    xData = reshape(xData, [size(xData, 1), sizeX(2:end)]);
end

% Update output series
this = fill(this, xData, extendedRange(1));

return

    function hereCheckMissingObs( )
        inxFinite = all(isfinite(xData(posDates, :)), 2);
        if any(~inxFinite)
            thisWarning = [ 
                "NumericTimeSubscriptable:OutputWithMissingObs"
                "Output time series contains Inf or NaN data" 
            ];
            throw(exception.Base(thisWarning, 'warning'));
        end
    end%
end%

