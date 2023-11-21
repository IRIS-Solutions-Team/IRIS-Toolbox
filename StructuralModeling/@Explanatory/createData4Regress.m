% createData4Regress  Create data matrices for Explanatory model
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [lhs, rhs, x] = createData4Regress(this, dataBlock, controls)

if numel(this)~=1
    exception.error([ 
        "Explanatory:SingleEquationExpected"
        "Method @Explanatory/createData4Regress expects "
        "a scalar Explanatory object."
    ]);
end

%--------------------------------------------------------------------------

%
% Create array of plain data for this single Explanatory inclusive of
% `ResidualName` (ordered last)
%
x = dataBlock.YXEPG(this.Runtime.PosPlainData, :, :);

numExtendedPeriods = size(x, 2);
numPages = size(x, 3);
baseRangeColumns = dataBlock.BaseRangeColumns;

%
% Model data for the dependent term
%
lhs = nan(1, numExtendedPeriods, numPages);
lhs(1, baseRangeColumns, :) = createModelData(this.DependentTerm, x, baseRangeColumns, controls);

%
% Model data for all explanatory terms for linear regressions
%
if this.LinearStatus
    rhs = nan(numel(this.ExplanatoryTerms), numExtendedPeriods, numPages);
    rhs(:, baseRangeColumns, :) = createModelData(this.ExplanatoryTerms, x, baseRangeColumns, controls);
else
    rhs = zeros(0, numExtendedPeriods, 1);
end

end%

