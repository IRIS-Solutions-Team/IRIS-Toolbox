function this = apct(this, varargin)
% apct  Annualized percent rate of change
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.apct');
    parser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    parser.addOptional('Shift', -1, @(x) isnumeric(x) && isscalar(x) && x==round(x));
    parser.addOptional('Power', @auto, @(x) isequal(x, @auto) || (isscalar(x) && isnumeric(x)) );
end
parser.parse(this, varargin{:});
shift = parser.Results.Shift;
power = parser.Results.Power;

if isequal(power, @auto)
    freq = DateWrapper.getFrequencyAsNumeric(this.Start);
    if freq==0
        power = 1;
    elseif abs(shift)==1
        power = freq;
    else
        power = freq / abs(shift);
    end
end

%--------------------------------------------------------------------------

if isempty(this.Data)
    return
end

this = unop(@numeric.pct, this, 0, shift, power);

end%

