% moving  Apply function to moving window of time series observations
%{
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
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% >=R2019b
%[
function this = moving(this, range, opt)

arguments
    this NumericTimeSubscriptable
    range {validate.rangeInput(range)} = Inf

    opt.Window {locallyValidateWindow(opt.Window)} = @auto
    opt.Function {mustBeA(opt.Function, "function_handle")} = @mean
end
%]
% >=R2019b

% <=R2019a
%{
function this = moving(this, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Series/moving');
    pp.addRequired('inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    pp.addOptional('range', Inf, @DateWrapper.validateRangeInput);
    pp.addParameter('Function', @mean, @(x) isa(x, 'function_handle'));
    pp.addParameter('Window', @auto, @(x) isequal(x, @auto) || isnumeric(x));
end
opt = pp.parse(this, varargin{:});
range = pp.Results.range;
%}
% <=R2019a

opt.Window = locallyResolveWindow(opt.Window, this);

%--------------------------------------------------------------------------

if ~isequal(range, @all) && ~isequal(range, Inf)
    range = double(range);
    this = clip(this, range(1), range(end));
end

this = unop(@numeric.moving, this, 0, opt.Window, opt.Function);

end%


%
% Local Validators
%


function window = locallyResolveWindow(window, inputSeries)
    if isnumeric(window) 
        if ~all(window==round(window))
            thisError = [
                "Series:InvalidMovingWindow"
                "Option Window= in @Series/moving must be "
                "a vector of integer values specifying lags and leads. "
            ];
            throw(exception.Base(thisError, 'error'));
        end
        window = reshape(window, 1, [ ]);
        return
    end
    freq = dater.getFrequency(inputSeries.Start);
    if freq==0
        thisError = [
            "Series:InvalidMovingWindow"
            "Options Window= in @Series/moving cannot be set to @auto "
            "for time series of INTEGER frequency. "
        ];
        throw(exception.Base(thisError, 'error'));
    end
    window = (-freq+1):0;
end%


function locallyValidateWindow(input)
    if isa(input, "function_handle")
        return
    end
    if isnumeric(input) && all(input==round(input))
        return
    end
    error("Validation:Failed", "Input value must be an array of integers");
end%

