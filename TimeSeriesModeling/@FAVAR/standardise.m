function [this,y] = standardise(this,y)

docompute = isempty(this.Mean) || isempty(this.Std);
   
nper = size(y,2);
repeat = ones([1,nper]);
nanindex = isnan(y);
y(nanindex) = 0;
if docompute
   count = sum(~nanindex,2);
   this.Mean = sum(y,2) ./ count;
end
y = y - this.Mean(:,repeat);
y(nanindex) = 0;
if docompute
   this.Std = sqrt(sum(y.^2,2) ./ count);
end
y = y ./ this.Std(:,repeat);
y(nanindex) = NaN;

end