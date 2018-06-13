function [this, y] = stdize(this, y)

docompute = isempty(this.Mean) || isempty(this.Std);
   
numPeriods = size(y, 2);
repeat = ones(1, numPeriods);
indexNaN = isnan(y);
y(indexNaN) = 0;
if docompute
   count = sum(~indexNaN, 2);
   this.Mean = sum(y, 2) ./ count;
end
y = y - this.Mean(:, repeat);
y(indexNaN) = 0;
if docompute
   this.Std = sqrt(sum(y.^2, 2) ./ count);
end
y = y ./ this.Std(:, repeat);
y(indexNaN) = NaN;

end
