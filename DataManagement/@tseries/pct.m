function this = pct(this, varargin)
% pct  Percent rate of change
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = pct(X, ~Shift, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input tseries object.
%
% * `~Shift` [ numeric ] - Time shift (lag or lead) over which the rate of
% change will be computed, i.e. between time t and t+k; if omitted,
% `Shift=-1`.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Percentage rate of change in the input data.
%
%
% __Options__
%
% * `'OutputFreq='` [ *empty* | Frequency | `1` | `2` | `4` | `6` | `12` |
% `52` | `365` ] - Convert the rate of change to the requested date
% frequency; empty means plain rate of change with no conversion.
%
%
% __Description__
%
%
% __Example__
%
% In this example, `X` is a monthly time series. The following command
% computes the annualised rate of change between month t and t-1:
%
%     pct(X, -1, 'OutputFreq=', 1)
%
% while the following line computes the annualised rate of change between
% month t and t-3:
%
%     pct(X, -3, 'OutputFreq=', 1)
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries/pct');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addOptional('Shift', -1, @(x) isnumeric(x) && isscalar(x) && x==round(x));
    INPUT_PARSER.addParameter('OutputFreq', [ ], @(x) isempty(x) || isa(Frequency(x), 'Frequency'));
end
INPUT_PARSER.parse(this, varargin{:});
sh = INPUT_PARSER.Results.Shift;
outputFreq = INPUT_PARSER.Results.OutputFreq;
opt = INPUT_PARSER.Options;

%--------------------------------------------------------------------------

if isempty(this.data)
    return
end

Q = 1;
if ~isempty(opt.OutputFreq)
    inputFreq = DateWrapper.getFrequencyFromNumeric(this.start);
    Q = inputFreq / opt.OutputFreq / abs(sh);
end

this = unop(@numeric.pct, this, 0, sh, Q);

end
