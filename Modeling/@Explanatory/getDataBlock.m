function varargout = getDataBlock(this, inputDatabank, range, lhsRequired, context)
% getDataBlock  Get DataBlock of all time series for LHS and RHS names
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==2 && isequal(inputDatabank, '--test')
    varargout{1} = unitTests( );
    return
end
%)

%--------------------------------------------------------------------------

range = double(range);
startDate = range(1);
endDate = range(end);
numEquations = numel(this);
maxLag = min([0, this(:).MaxLag]);
maxLead = max([0, this(:).MaxLead]);
extendedStartDate = DateWrapper.roundPlus(startDate, maxLag);
extendedEndDate = DateWrapper.roundPlus(endDate, maxLead);
extendedRange = DateWrapper.roundColon(extendedStartDate, extendedEndDate);

[variableNames, residualNames] = collectAllNames(this);
allNames = [variableNames, residualNames];

if lhsRequired
    %
    % All LHS names are required to be in the input databank even if they
    % do not occur on the RHS in the Explanatory terms
    %
    requiredNames = variableNames;
    optionalNames = residualNames;
else
    %
    % LHS names are required to be in the input databank only if they occur
    % on the RHS in the Explanatory terms
    %
    inxLhsOptional = ~[this.RhsContainsLhsName];
    lhsNames = [this.LhsName];
    requiredNames = setdiff(variableNames, lhsNames(inxLhsOptional));
    optionalNames = [lhsNames(inxLhsOptional), residualNames];
end

scalarAllowed = @all;
databankInfo = checkInputDatabank( ...
    this, inputDatabank, extendedRange, ...
    requiredNames, optionalNames, context, ...
    scalarAllowed ...
);

data = shared.DataBlock( );
data.Names = allNames;
data.ExtendedRange = extendedRange;
data.YXEPG = requestData(this, databankInfo, inputDatabank, extendedRange, allNames);

numExtendedPeriods = numel(extendedRange);
inxBaseRangeColumns = true(1, numExtendedPeriods);
inxBaseRangeColumns(1:abs(maxLag)) = false;
inxBaseRangeColumns = fliplr(inxBaseRangeColumns);
inxBaseRangeColumns(1:abs(maxLead)) = false;
inxBaseRangeColumns = fliplr(inxBaseRangeColumns);
data.BaseRangeColumns = find(inxBaseRangeColumns);

varargout = {data, maxLag, maxLead};

end%




%
% Unit Tests
%(
function tests = unitTests( )
    tests = functiontests({
        @setupOnce 
        @getDataBlockTest
    });
    tests = reshape(tests, [ ], 1);
end%


function setupOnce(testCase)
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
end%


function getDataBlockTest(testCase)
    g = testCase.TestData.Model1;
    db = testCase.TestData.Databank;
    baseRange = testCase.TestData.BaseRange;
    extendedRange = testCase.TestData.ExtendedRange;
    numExtendedPeriods = numel(extendedRange);
    lhsRequired = true;
    act = getDataBlock(g, db, baseRange, lhsRequired, "");
    assertEqual(testCase, act.NumOfExtendedPeriods, numExtendedPeriods);
    exp_YXEPG = nan(7, numExtendedPeriods);
    exp_YXEPG(1, :) = db.x(extendedRange);
    exp_YXEPG(2, :) = db.a(extendedRange);
    exp_YXEPG(3, :) = db.b(extendedRange);
    exp_YXEPG(4, :) = db.c(extendedRange);
    exp_YXEPG(5, :) = db.z(extendedRange);
    exp_YXEPG(6, :) = db.d(extendedRange);
    exp_YXEPG(7, :) = db.res_x(extendedRange);
    assertEqual(testCase, act.YXEPG, exp_YXEPG);
end%
%)
