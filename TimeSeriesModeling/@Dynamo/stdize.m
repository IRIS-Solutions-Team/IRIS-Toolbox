function [this, y] = stdize(this, y)

numPeriods = size(y, 2);
inxNa = isnan(y);
y(inxNa) = 0;
count = sum(~inxNa, 2);

if isempty(this.Mean)
   this.Mean = sum(y, 2) ./ count;
end
y = y - this.Mean;
y(inxNa) = 0;

if isempty(this.Std)
   this.Std = sqrt(sum(y.^2, 2) ./ count);
end
y = y ./ this.Std;
y(inxNa) = NaN;

end%

