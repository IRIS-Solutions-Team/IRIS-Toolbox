function this = moving(this, varargin)
% moving  Apply function to moving window of time series observations
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = moving(X, ~Range, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input times series.
%
% * `~Range` [ numeric | char | *`@all`* ] - Date range from which input
% time series date will be used; `@all` means the entire range on which the
% input time series `X` is defined.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Output time series.
%
%
% __Options__
%
% * `Function=@mean` [ function_handle ] - Function to be applied to
% moving window of observations.
%
% * `Window=@auto` [ numeric | `@auto` ] - The window of observations where
% 0 means the current date, -1 means one period lag, etc.; `@auto` means
% that the last N observations (including the current one) are used, where
% N is the frequency of the input data.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.moving');
    inputParser.addRequired('InputTimeSeries', @(x) isa(x, 'tseries'));
    inputParser.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
    inputParser.addParameter('Function', @mean, @(x) isa(x, 'function_handle'));
    inputParser.addParameter('Window', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && all(x==round(x))));
end
inputParser.parse(this, varargin{:});
range = inputParser.Results.Range;
opt = inputParser.Options;

%--------------------------------------------------------------------------

if isequal(opt.Window, @auto)
    freq = DateWrapper.getFrequencyFromNumeric(this.start);
    assert( ...
        freq~=0, ...
        [class(this), ':moving'], ...
        'Option Window= must be specified when input time series is of integer date frequency.' ...
    );
    opt.Window = (-freq+1):0;
end

if ~isequal(range, @all) && ~isequal(range, Inf)
    this = resize(this, range);
end

this = unop(@numeric.moving, this, 0, opt.Window, opt.Function);

end
