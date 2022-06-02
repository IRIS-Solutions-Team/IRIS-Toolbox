% Type `web Series/rebase.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team


% >=R2019b
%{
function [this, priorValue, reciprocal] = rebase(this, basePeriods, baseValue, opt)
arguments
    this Series
    basePeriods double
    baseValue (1, 1) double

    opt.Mode {local_validateMode} = "auto"
    opt.Reciprocal {local_validateReciprocal} = []
    opt.Aggregator = "auto"
end
%}
% >=R2019b


% <=R2019a
%(
function [this, priorValue, reciprocal] = rebase(this, basePeriods, baseValue, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Mode', "auto", @local_validateMode);
    addParameter(ip, 'Reciprocal', []);
    addParameter(ip, 'Aggregator', "auto");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


reciprocal = opt.Reciprocal;
isReciprocal = ~isempty(reciprocal);


if startsWith(opt.Mode, "add") ...
    || (startsWith(opt.Mode, "auto") && baseValue==0)
    func = @plus;
    invFunc = @minus;
    aggregator = opt.Aggregator;
    if all(strcmpi(aggregator, 'auto'))
        aggregator = @mean;
    end
else
    func = @times;
    invFunc = @rdivide;
    aggregator = opt.Aggregator;
    if all(strcmpi(aggregator, 'auto'))
        aggregator = @geomean;
    end
end


if ischar(basePeriods) || isstring(basePeriods)
    basePeriods = get(this, basePeriods);
end
basePeriods = reshape(basePeriods, 1, []);

%
% Frequency check
%
freqBasePeriod = dater.getFrequency(basePeriods);
freqInput = getFrequencyAsNumeric(this);
if any(isnan(basePeriods)) || any(freqBasePeriod~=freqInput)
    this = this.empty(this);
    if isReciprocal
        reciprocal = reciprocal.empty(reciprocal);
    end
    return
end


%
% Get prior value and calculate correction
%
priorValue = getDataFromTo(this, basePeriods);
if size(priorValue, 1)>1
    priorValue = aggregator(priorValue, 1);
end
correction = invFunc(baseValue, priorValue);


sizeData = size(this.Data);
for i = 1 : prod(sizeData(2:end))
    this.Data(:, i) = func(this.Data(:, i), correction(1, i));
    if isReciprocal
        reciprocal.Data(:, i) = invFunc(reciprocal.Data(:, i), correction(1, i));
    end
end

this = trim(this);
if isReciprocal
    reciprocal = trim(reciprocal);
end

end%

%
% Local validators
%

function local_validateMode(x)
    %(
    if isstring(x) && isscalar(x) && startsWith(x, ["auto", "add", "mult"])
        return
    end
    error("Input value must be one of {""auto"", ""additive"", ""multiplicative""}.");
    %)
end%


function local_validateReciprocal(x)
    %(
    if isempty(x) || isa(x, 'Series')
        return
    end
    error("Input value must be empty or a time series.");
    %)
end%

