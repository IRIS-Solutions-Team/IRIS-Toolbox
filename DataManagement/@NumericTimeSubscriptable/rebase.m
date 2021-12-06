% Type `web Series/rebase.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function ...
    [this, priorValue, reciprocal] ...
    = rebase(this, basePeriod, baseValue, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('tseries.rebase');
    pp.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    pp.addRequired('BasePeriod', @(x) any(strcmpi(x, {'AllStart', 'AllEnd'})) || validate.date(x));
    pp.addRequired('BaseValue', @(x) isnumeric(x) && isscalar(x));

    pp.addParameter('Mode', "auto", @locallyValidateMode);
    pp.addParameter('Reciprocal', [], @locallyValidateReciprocal);
    pp.addParameter('Aggregator', "auto");
end
options = pp.parse(this, basePeriod, baseValue, varargin{:});


reciprocal = options.Reciprocal;
isReciprocal = ~isempty(reciprocal);


if startsWith(options.Mode, "add") ...
    || (startsWith(options.Mode, "auto") && baseValue==0)
    func = @plus;
    invFunc = @minus;
    aggregator = options.Aggregator;
    if isequal(aggregator, "auto")
        aggregator = @mean;
    end
else
    func = @times;
    invFunc = @rdivide;
    aggregator = options.Aggregator;
    if isequal(aggregator, "auto")
        aggregator = @geomean;
    end
end


if ischar(basePeriod) || isstring(basePeriod)
    basePeriod = get(this, basePeriod);
end
basePeriod = reshape(basePeriod, 1, []);

%
% Frequency check
%
freqBasePeriod = dater.getFrequency(basePeriod);
freqInput = getFrequencyAsNumeric(this);
if any(isnan(basePeriod)) || any(freqBasePeriod~=freqInput)
    this = this.empty(this);
    if isReciprocal
        reciprocal = reciprocal.empty(reciprocal);
    end
    return
end


%
% Get prior value and calculate correction
%
priorValue = getDataFromTo(this, basePeriod);
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

function locallyValidateMode(x)
    %(
    if isstring(x) && isscalar(x) && startsWith(x, ["auto", "add", "mult"])
        return
    end
    error("Input value must be one of {""auto"", ""additive"", ""multiplicative""}.");
    %)
end%


function locallyValidateReciprocal(x)
    %(
    if isempty(x) || isa(x, 'Series')
        return
    end
    error("Input value must be empty or a time series.");
    %)
end%

