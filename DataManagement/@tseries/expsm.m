function [this, sse, beta] = expsm(this, beta, range, varargin)
% expsm  Exponential smoothing
%
% __Syntax__
%
%     X = expsm(X, Beta, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series.
%
% * `Beta` [ numeric ] - Exponential factor.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Exponentially smoothed series.
%
%
% __Options__
%
% * `Init=NaN` [ numeric ] - Add this value before the first observation to
% initialise the smoothing.
%
% * `Log=false` [ `true` | `false` ] - Logarithmize the data before
% filtering, de-logarithmize afterwards.
%
%
% __Description__
%
%
% __Examples__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries.expsm');
    INPUT_PARSER.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    INPUT_PARSER.addRequired('Beta', @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=1);
    INPUT_PARSER.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
    INPUT_PARSER.addParameter('Init', NaN, @(x) isnumeric(x) && isscalar(x));
    INPUT_PARSER.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
    INPUT_PARSER.addParameter('ForecastHorizon', 0, @(x) isnumeric(x) && isscalar(x) && x>=0 && x==round(x));
end
INPUT_PARSER.parse(this, beta, varargin{:});
opt = INPUT_PARSER.Options;
range = INPUT_PARSER.Results.Range; 
if ischar(range)
    range = textinp2dat(range);
end

%--------------------------------------------------------------------------

[data, range] = getData(this, range);

if opt.Log
    data = 100*log(data);
end

[data, sse] = apply.expsm(data, beta, opt.Init, opt.ForecastHorizon);

if opt.Log
    data = exp(data/100);
end

this.Start = range(1);
this.Data = data;
this = trim(this);

end
