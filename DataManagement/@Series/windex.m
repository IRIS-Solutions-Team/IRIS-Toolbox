function [this, weights] = windex(this, weights, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('tseries.windex');
    pp.KeepUnmatched = true;
    pp.addRequired('InputSeries', @(x) isa(x, 'Series'));
    pp.addRequired('Weights', @(x) isnumeric(x) || isa(x, 'Series'));
    pp.addOptional('Range', Inf, @validate.range);
end
parse(pp, this, weights, varargin{:});
range = double(pp.Results.Range);
unmatched = pp.UnmatchedInCell;

%--------------------------------------------------------------------------

checkFrequency(this, range);
[inputData, from, to, range] = getDataFromTo(this, range);

if isa(weights, 'Series')
    checkFrequency(weights, range);
    weightsData = getDataFromTo(weights, from, to);
else
    weightsData = weights;
end

[outputData, weightsData] = numeric.windex(inputData, weightsData, unmatched{:});

weights = this;
weights.Start = range(1);
weights.Data = weightsData;
weights = resetComment(weights);
weights = trim(weights);

this.Start = range(1);
this.Data = outputData;
this = resetComment(this);
this = trim(this);

end%

