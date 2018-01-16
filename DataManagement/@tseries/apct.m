function this = apct(this, varargin)
% apct  Annualized percent rate of change
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.

%     X = apct(X, ~Shift)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series.
%
% * `Shift` [ numeric ] - Time shift, i.e. the number of periods over which
% the rate of change will be calculated; if omitted, `Shift` is `-1`.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Annualized percentage rate of change in the input
% data.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries.apct');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addOptional('Shift', -1, @(x) isnumeric(x) && isscalar(x) && x==round(x));
    INPUT_PARSER.addOptional('Power', @auto, @(x) isequal(x, @auto) || (isscalar(x) && isnumeric(x)) );
end
INPUT_PARSER.parse(this, varargin{:});
shift = INPUT_PARSER.Results.Shift;
power = INPUT_PARSER.Results.Power;

if isequal(power, @auto)
    frequency = DateWrapper.getFrequencyFromNumeric(this.Start);
    if frequency==0
        power = 1;
    elseif abs(shift)==1
        power = frequency;
    else
        power = frequency / abs(shift);
    end
end

%--------------------------------------------------------------------------

if isempty(this.data)
    return
end

this = unop(@numeric.pct, this, 0, shift, power);

end
