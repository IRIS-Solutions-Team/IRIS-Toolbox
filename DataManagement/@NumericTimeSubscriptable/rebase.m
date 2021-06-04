% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 IRIS Solutions Team

function this = rebase(this, varargin)

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
else
    func = @rdivide;
end

if ischar(basePeriod) || isa(basePeriod, 'string')
    if any(strcmpi(basePeriod, {'AllStart', 'AllEnd'}))
        basePeriod = get(this, basePeriod);
    else
        basePeriod = textinp2dat(basePeriod);
    end
end

% Frequency check
freqBasePeriod = dater.getFrequency(basePeriod);
freqInput = getFrequencyAsNumeric(this);
if isnan(basePeriod) || freqBasePeriod~=freqInput
    this = this.empty(this);
    return
end

sizeOfData = size(this.Data);
ndimsOfData = ndims(this.Data);
this.Data = this.Data(:,:);

y = getDataFromTo(this, basePeriod, basePeriod);
for i = 1 : size(this.Data, 2)
    this.Data(:,i) = func(this.Data(:,i), y(i));
end

if ndimsOfData>2
    this.Data = reshape(this.Data, sizeOfData);
end

if baseValue~=0 && baseValue~=1
    this.Data = this.Data * baseValue;
end

this = trim(this);

end%

