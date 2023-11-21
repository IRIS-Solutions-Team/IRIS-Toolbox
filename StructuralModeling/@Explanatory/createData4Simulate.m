% createData4Simulate  Create data matrices for Explanatory model
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [x, res] = createData4Simulate(this, dataBlock, controls)

if numel(this)~=1
    thisError = [ 
        "Explanatory:SingleEquationExpected"
        "Method @Explanatory/createData4Simulate expects "
        "a scalar Explanatory object."
    ];
    throw(exception.Base(thisError, 'error'));
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
% Model data for residuals; reset NaN residuals to zero
%
res = double.empty(0, numExtendedPeriods, numPages);
if nargout>=2 && ~this.IsIdentity && ~isempty(this.Runtime.PosResidualInDataBlock)
    res = dataBlock.YXEPG(this.Runtime.PosResidualInDataBlock, :, :);
    hereFixResidualValuesInBaseRange( );
end

return

    function hereFixResidualValuesInBaseRange( )
        %(
        res__ = res(:, baseRangeColumns, :);
        inxNaN = isnan(res__);
        if nnz(inxNaN)==0
            return
        end
        res__(inxNaN) = 0;
        res(:, baseRangeColumns, :) = res__;
        %)
    end%
end%


