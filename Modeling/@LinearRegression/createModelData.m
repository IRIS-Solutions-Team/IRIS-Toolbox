function [plain, y, X, e, inxBaseRangeColumns] = createModelData(this, inputDatabank, range)
% createModelData  Create data matrices for LinearRegression
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

numExplanatory = this.NumOfExplanatory;

%
% Plain matrix with data for each name in a row
%
[plain, inxBaseRangeColumns, extendedRange] = getPlainData(this, inputDatabank, range);
numExtendedPeriods = size(plain, 2);
numPages = size(plain, 3);

%
% Preallocate model matrices
%
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

if this.Intercept
    X = [ X; ones(1, numExtendedPeriods, numPages) ];
end

%
% Model data for residuals
%
e = plain(end, :, :);

end%

