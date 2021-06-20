% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 IRIS Solutions Team

function [this, rebaseValue] = rebase(this, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.rebase');
    inputParser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    inputParser.addOptional('BasePeriod', 'AllStart', @(x) any(strcmpi(x, {'AllStart', 'AllEnd'})) || validate.date(x));
    inputParser.addOptional('BaseValue', 1, @(x) isnumeric(x) && isscalar(x));
end
inputParser.parse(this, varargin{:});
basePeriod = inputParser.Results.BasePeriod;
baseValue = inputParser.Results.BaseValue;

%--------------------------------------------------------------------------

if baseValue==0
    func = @minus;
    aggregator = @mean;
else
    func = @rdivide;
    aggregator = @geomean;
end

if ischar(basePeriod) || isstring(basePeriod)
    basePeriod = get(this, basePeriod);
end

% Frequency check
freqBasePeriod = dater.getFrequency(basePeriod);
freqInput = getFrequencyAsNumeric(this);
if isnan(basePeriod) || freqBasePeriod~=freqInput
    this = this.empty(this);
    return
end

sizeData = size(this.Data);
ndimsData = ndims(this.Data);
this.Data = this.Data(:, :);

rebaseValue = getDataFromTo(this, basePeriod, basePeriod);
if size(rebaseValue, 1)>1
    rebaseValue = aggregator(rebaseValue, 1);
end
for i = 1 : size(this.Data, 2)
    this.Data(:,i) = func(this.Data(:,i), rebaseValue(i));
end

if ndimsData>2
    this.Data = reshape(this.Data, sizeData);
end

if baseValue~=0 && baseValue~=1
    this.Data = this.Data * baseValue;
end

this = trim(this);

end%

