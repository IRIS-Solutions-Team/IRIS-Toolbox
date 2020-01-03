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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.moving');
    parser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    parser.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
    parser.addParameter('Function', @mean, @(x) isa(x, 'function_handle'));
    parser.addConditional('Window', @auto, @validateWindow);
end
parser.parse(this, varargin{:});
range = parser.Results.Range;
opt = parser.Options;

%--------------------------------------------------------------------------

if isequal(opt.Window, @auto)
    freq = DateWrapper.getFrequencyAsNumeric(this.Start);
    opt.Window = (-freq+1):0;
end

if ~isequal(range, @all) && ~isequal(range, Inf)
    this = resize(this, range);
end

this = unop(@numeric.moving, this, 0, opt.Window, opt.Function);

end%


%
% Validators
%


function flag = validateWindow(input)
    freq = input.InputSeries.FrequencyAsNumeric;
    if isequal(input.Window, @auto)
        flag = freq>0;
        return
    end
    flag = isnumeric(input.Window) && all(input.Window==round(input.Window));
end%

