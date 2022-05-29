% getDataBlock  Get DataBlock of all time series for LHS and RHS names
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [data, maxLag, maxLead] = getDataBlock(this, inputData, range, lhsRequired, context)

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

if lhsRequired
    %
    % All LHS names are required to be in the input databank even if they
    % do not occur on the RHS in the Explanatory terms (estimation)
    %
    requiredNames = variableNames;
    optionalNames = residualNames;
else
    %
    % LHS names are required to be in the input databank only if they occur
    % on the RHS in the Explanatory terms (simulation)
    %
    inxLhsOptional = ~[this.RhsContainsLhsName];
    lhsNames = [this.LhsName];
    requiredNames = [setdiff(variableNames, lhsNames(inxLhsOptional))];
    optionalNames = [lhsNames(inxLhsOptional), residualNames];
end


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




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/getDataBlockUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up once
    testCase.TestData.Model1 = Explanatory.fromString("log(x) = ?*a + b*x{-1} + ?*log(c) + ?*z{+1} - ? + d"); baseRange = qq(2001,1) : qq(2010,10);
    extendedRange = baseRange(1)-1 : baseRange(end)+1;
    db = struct( );
    db.x = Series(extendedRange, @rand);
    db.a = Series(baseRange, @rand);
    db.b = Series(baseRange, @rand);
    db.c = Series(baseRange, @rand);
    db.d = Series(extendedRange, @rand);
    db.z = Series(extendedRange, @rand);
    db.res_x = Series(extendedRange(5:10), @rand);
    testCase.TestData.BaseRange = baseRange;
    testCase.TestData.ExtendedRange = extendedRange;
    testCase.TestData.Databank = db;


%% Test Plain Vanilla
    g = testCase.TestData.Model1;
    db = testCase.TestData.Databank;
    baseRange = testCase.TestData.BaseRange;
    extendedRange = testCase.TestData.ExtendedRange;
    numExtendedPeriods = numel(extendedRange);
    lhsRequired = true;
    act = getDataBlock(g, db, baseRange, lhsRequired, "");
    assertEqual(testCase, act.NumExtdPeriods, numExtendedPeriods);
    exp_YXEPG = nan(7, numExtendedPeriods);
    exp_YXEPG(1, :) = db.x(extendedRange);
    exp_YXEPG(2, :) = db.a(extendedRange);
    exp_YXEPG(3, :) = db.b(extendedRange);
    exp_YXEPG(4, :) = db.c(extendedRange);
    exp_YXEPG(5, :) = db.z(extendedRange);
    exp_YXEPG(6, :) = db.d(extendedRange);
    exp_YXEPG(7, :) = db.res_x(extendedRange);
    assertEqual(testCase, act.YXEPG, exp_YXEPG);

##### SOURCE END #####
%}
