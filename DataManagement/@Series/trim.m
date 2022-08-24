% trim  Remove leading and trailing missing values from time series data
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = trim(this, inxAllMissing)

newData = this.Data;
if isempty(newData)
    return
end

if nargin<2
    if isequaln(this.MissingTest, @isnan)
        inxAllMissing = all(isnan(newData(:, :)), 2);
    else
        inxAllMissing = all(this.MissingTest(newData(:, :)), 2);
    end
end

if ~inxAllMissing(1) && ~inxAllMissing(end)
    return
end

oldStart = double(this.Start);
newStart = oldStart;
sizeData = size(newData);
x = newData;
if all(inxAllMissing)
    missingValue = this.MissingValue;
    newData = repmat(missingValue, [0, sizeData(2:end)]);
    newStart = NaN;
else
    pos = find(~inxAllMissing);
    first = pos(1);
    last = pos(end);
    newData = newData(first:last, :);
    if numel(sizeData)>2
        newData = reshape(newData, [last-first+1, sizeData(2:end)]);
    end
    newStart = (100*newStart + 100*(first - 1)) / 100;
end

this.Data = newData;
this.Start = newStart;

end%

