function this = expsm(this, beta, varargin)
% expsm  Exponential smoothing
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = expsm(X, Beta, ~Range, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series.
%
% * `Beta` [ numeric ] - Exponential factor.
%
% * `~Range` [ DateWrapper ] - Range on which the exponential smoothing will
% be performed; if omitted, the entire time series range is used.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Exponentially smoothed series.
%
%
% __Options__
%
% * `Init=NaN` [ numeric ] - Use this value before the first observation to
% initialize the smoothing.
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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries.expsm');
    INPUT_PARSER.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    INPUT_PARSER.addRequired('Beta', @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=1);
    INPUT_PARSER.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
    INPUT_PARSER.addParameter('Init', NaN, @(x) isnumeric(x) && isscalar(x));
    INPUT_PARSER.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
end
INPUT_PARSER.parse(this, beta, varargin{:});
range = INPUT_PARSER.Results.Range; 
if ischar(range) || isa(range, 'string')
    range = textinp2dat(range);
end
opt = INPUT_PARSER.Options;

%--------------------------------------------------------------------------

[data, range] = getData(this, range);

if opt.Log
    data = 100*log(data);
end

data = numeric.expsm(data, beta, opt.Init);

if opt.Log
    data = exp(data/100);
end

this.Start = range(1);
this.Data = data;
this = trim(this);

end
