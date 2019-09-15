function [plain, y, X, e, inxBaseRangeColumns] = createModelData(this, inputDatabank, range)

[plain, inxBaseRangeColumns, extendedRange] = getPlainData(this, inputDatabank, range);

numExplanatory = this.NumOfExplanatory;
numExtendedPeriods = size(plain, 2);
numPages = size(plain, 3);

y = nan(1, numExtendedPeriods, numPages);
X = nan(numExplanatory, numExtendedPeriods, numPages);

%
% Model data for dependent term
%
y(:, inxBaseRangeColumns, :) = createModelData(this.Dependent, plain, inxBaseRangeColumns);

%
% Model data for all explanatory terms
%
for i = 1 : numExplanatory
    ithX = createModelData(this.Explanatory(i), plain, inxBaseRangeColumns);
    X(i, inxBaseRangeColumns, :) = ithX;
end

if this.Constant
    const = ones(1, numExtendedPeriods, numPages);
    X = [X; const];
end

e = plain(end, :, :);

end%

