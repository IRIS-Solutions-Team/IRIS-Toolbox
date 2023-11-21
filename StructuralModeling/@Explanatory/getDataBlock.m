% getDataBlock  Get DataBlock of all time series for LHS and RHS names
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [data, maxLag, maxLead] = getDataBlock( ...
    this, inputData, range, requiredNames, optionalNames, context ...
)

%--------------------------------------------------------------------------

[maxLag, maxLead] = getActualMinMaxShifts(this);
range = double(range);
startDate = range(1);
endDate = range(end);
extStartDate = dater.plus(startDate, maxLag);
extEndDate = dater.plus(endDate, maxLead);
extdRange = dater.colon(extStartDate, extEndDate);
numExtPeriods = numel(extdRange);

[variableNames, residualNames, ~, ~] = collectAllNames(this);
variableNames = setdiff(variableNames, residualNames, "stable");

%
% The same LHS name can appear in multiple equations, make sure both the
% required and optional names are uniques lists
%
requiredNames = unique(requiredNames, "stable");
optionalNames = unique(optionalNames, "stable");
allNames = unique([variableNames, residualNames], "stable");


data = iris.mixin.DataBlock( );
data.Names = allNames;
data.ExtendedRange = extdRange;

if isa(inputData, 'iris.mixin.DataBlock')
    data.YXEPG = hereGetDataFromDataBlock( );
else
    data.YXEPG = hereGetDataFromDatabank( );
end

inxBaseRangeColumns = true(1, numExtPeriods);
inxBaseRangeColumns(1:abs(maxLag)) = false;
inxBaseRangeColumns = fliplr(inxBaseRangeColumns);
inxBaseRangeColumns(1:abs(maxLead)) = false;
inxBaseRangeColumns = fliplr(inxBaseRangeColumns);
data.BaseRangeColumns = find(inxBaseRangeColumns);

return

    function YXEPG = hereGetDataFromDatabank( )
        allowedNumeric = @all;
        allowedLog = string.empty(1, 0);
        context = "";
        dbInfo = checkInputDatabank( ...
            this, inputData, extdRange ...
            , requiredNames, optionalNames ...
            , allowedNumeric, allowedLog ...
            , context ...
        );
        YXEPG = requestData( ...
            this, dbInfo, inputData ...
            , allNames, extdRange ...
        );
    end%


    function YXEPG = hereGetDataFromDataBlock( )
        numPages = size(inputData.YXEPG, 3);
        numAllNames = numel(allNames);
        YXEPG = nan(numAllNames, numExtPeriods, numPages);
        allNames = string(allNames);
        namesInputData = string(inputData.Names);
        for i = 1 : numAllNames
            inx = allNames(i)==namesInputData;
            if any(inx)
                YXEPG(i, :, :) = inputData.YXEPG(inx, :, :);
            end
        end
    end%
end%

