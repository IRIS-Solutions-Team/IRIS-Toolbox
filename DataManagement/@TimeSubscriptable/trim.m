% trim  Remove leading and trailing missing values from time series data
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = trim(this)

newData = this.Data;
if isempty(newData)
    return
end

if isequaln(this.MissingValue, NaN)
    inxAllMissing = all(isnan(newData(:, :)), 2);
else
    inxAllMissing = all(this.MissingTest(newData(:, :)), 2);
end

if ~inxAllMissing(1) && ~inxAllMissing(end)
    return
end

oldStart = double(this.Start);
newStart = oldStart;
sizeData = size(newData);
if all(inxAllMissing)
    missingValue = this.MissingValue;
    newData = repmat(missingValue, [0, sizeData(2:end)]);
    newStart = NaN;
else
    first = find(~inxAllMissing, 1);
    last = find(~inxAllMissing, 1, 'last');
    n = last - first + 1;
    newData = reshape(newData(first:last, :), [n, sizeData(2:end)]);
    newStart = dater.plus(newStart, first - 1);
end

this.Data = newData;
this.Start = newStart;

end%

