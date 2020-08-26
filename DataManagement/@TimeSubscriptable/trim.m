% trim  Remove leading and trailing missing values from time series data
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = trim(this)

newData = this.Data;
if isempty(newData)
    return
end

missingTest = this.MissingTest;
if ~all(missingTest(newData(1, :))) && ~all(missingTest(newData(end, :)))
    return
end

oldStart = double(this.Start);
newStart = oldStart;
sizeData = size(newData);
inxMissing = all(missingTest(newData(:, :)), 2);
if all(inxMissing)
    missingValue = this.MissingValue;
    newData = repmat(missingValue, [0, sizeData(2:end)]);
    newStart = NaN;
else
    first = find(~inxMissing, 1);
    last = find(~inxMissing, 1, 'last');
    n = last - first + 1;
    newData = reshape(newData(first:last, :), [n, sizeData(2:end)]);
    newStart = dater.plus(double(newStart), first - 1);
end

this.Data = newData;
if round(oldStart)~=round(newStart)
    if isa(this.Start, 'DateWrapper') && ~isa(newStart, 'DateWrapper')
        this.Start = DateWrapper(newStart);
    else
        this.Start = newStart;
    end
end

end%

