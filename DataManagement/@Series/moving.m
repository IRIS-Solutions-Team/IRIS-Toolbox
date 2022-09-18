% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function this = moving(this, legacyRange, opt)

arguments
    this Series
    legacyRange {validate.mustBeRange(legacyRange)} = Inf

    opt.Window {locallyValidateWindow(opt.Window)} = @auto
    opt.Function {validate.mustBeA(opt.Function, "function_handle")} = @mean
    opt.Period (1, 1) logical = false
    opt.Range (1, :) {validate.mustBeRange} = Inf
end
%}
% >=R2019b


% <=R2019a
%(
function this = moving(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, "legacyRange", Inf, @isnumeric);

    addParameter(ip, "Window", @auto);
    addParameter(ip, "Function", @mean);
    addParameter(ip, "Period", false);
    addParameter(ip, "Range", Inf);
end
parse(ip, varargin{:});
legacyRange = ip.Results.legacyRange;
opt = ip.Results;
%)
% <=R2019a


% Legacy input argument
if isequal(opt.Range, Inf) && ~isequal(legacyRange, Inf)
    opt.Range = legacyRange;
    exception.warning([
        "Deprecated"
        "Date range as a second input argument is obsolete, and will be"
        "disabled in a future version. Use the option Range= instead."
    ]);
end

if ~isequal(opt.Range, @all) && ~isequal(opt.Range, Inf)
    this = clip(this, opt.Range);
end

if ~isempty(opt.Window)
    freq = dater.getFrequency(this.Start);
    this.Data = series.moving(this.Data, freq, opt.Window, opt.Function, this.MissingValue, this.MissingTest, opt.Period);
    this = trim(this);
else
    this = emptyData(this);
end

end%

%
% Local validators
%

function locallyValidateWindow(input)
    %(
    if isa(input, 'function_handle')
        return
    end
    isInteger = isnumeric(input) && all(input==round(input));
    if isInteger && isreal(input)
        return
    end
    if isInteger && ~isreal(input) && isscalar(input)
        return
    end
    error("Validation:Failed", "Input value must be an array of integers or a complex integer scalar");
    %)
end%

