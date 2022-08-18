function this = interp(this, varargin)

if isempty(this)
    return
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.interp');
    inputParser.addOptional('Range', Inf, @isnumeric);
    inputParser.addParameter('Method', 'pchip', @(x) ischar(x) || isa(x, 'string'));
end
inputParser.parse(varargin{:});
opt = inputParser.Results;

%--------------------------------------------------------------------------

[data, actualStart] = getDataFromTo(this, opt.Range);

if isempty(data)
    this = this.empty(this);
    return
end

sizeOfData = size(data);
numOfPeriods = sizeOfData(1);
numOfColumns = prod( sizeOfData(2:end) );
grid = transpose(1 : numOfPeriods);
for i = 1 : numOfColumns
    inxOfData = ~isnan(data(:, i));
    if any(~inxOfData)
        func = griddedInterpolant(grid(inxOfData), data(inxOfData, i), opt.Method);
        data(~inxOfData, i) = func(grid(~inxOfData));
    end
end

this = fill(this, data, actualStart);

end%

