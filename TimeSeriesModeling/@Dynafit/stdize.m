function [this, y] = stdize(this, y)

numPages = size(y, 3);
nv = countVariants(this);
numRuns = max([numPages, nv]);
numObserved = this.NumObserved;

if numPages==1 && numRuns>1
    y = repmat(y, 1, 1, numRuns);
end

if isempty(this.Mean)
    this.Mean = nan(numObserved, nv);
end

if isempty(this.Std)
    this.Std = nan(numObserved, nv);
end

% TODO: Support for multiple runs

inxNa = isnan(y);
y(inxNa) = 0;
count = sum(~inxNa, 2);

inxNaMean = isnan(this.Mean);
if any(inxNaMean)
   this.Mean(inxNaMean) ...
       = sum(y(inxNaMean, :, :), 2) ./ count(inxNaMean, :, :);
end
y = y - this.Mean;
y(inxNa) = 0;

inxNaStd = isnan(this.Std);
if any(inxNaStd)
    this.Std(inxNaStd) ...
        = sqrt(sum(y(inxNaStd, :, :).^2, 2) ./ count(inxNaStd, :, :));
end
y = y ./ this.Std;

y(inxNa) = NaN;

end%

