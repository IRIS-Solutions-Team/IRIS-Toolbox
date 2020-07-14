% createModelData  Create data matrices for Explanatory model
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [plainData, lhs, rhs, res] = createModelData(this, dataBlock, controls)

if numel(this)~=1
    thisError = [ 
        "Explanatory:SingleEquationExpected"
        "Method @Explanatory/createModelData expects "
        "a scalar Explanatory object."
    ];
    throw(exception.Base(thisError, 'error'));
end

%--------------------------------------------------------------------------

%
% Create array of plain data for this single Explanatory inclusive of
% `ResidualName` (ordered last)
%
plainData = dataBlock.YXEPG(this.Runtime.PosPlainData, :, :);

numExtendedPeriods = size(plainData, 2);
numPages = size(plainData, 3);
baseRangeColumns = dataBlock.BaseRangeColumns;
baseRange = dataBlock.BaseRange;

%
% Model data for the dependent term
%
lhs = nan(1, numExtendedPeriods, numPages);
lhs(1, baseRangeColumns, :) = createModelData( ...
    this.DependentTerm, plainData, baseRangeColumns, baseRange, controls ...
);

%
% Model data for all explanatory terms
%
rhs = nan(numel(this.ExplanatoryTerms), numExtendedPeriods, numPages);
rhs(:, baseRangeColumns, :) = createModelData( ...
    this.ExplanatoryTerms, plainData, baseRangeColumns, baseRange, controls ...
);

%
% Model data for residuals; reset NaN residuals to zero
%
res = double.empty(0, numExtendedPeriods, numPages);
if nargout>=4 && ~this.IsIdentity && ~isempty(this.Runtime.PosResidualInDataBlock)
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




%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/createModelDataUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once
    testCase.TestData.Model1 = Explanatory.fromString("log(x) = @*a + b*x{-1} + @*log(c) + @*y{+1} - @ + d");
    testCase.TestData.Model2 = Explanatory.fromString("log(m) = @*a + b*m{-1} + @*log(c) + @*n{+1} - @ + d");
    baseRange = qq(2001,1) : qq(2010,10);
    extdRange = baseRange(1)-1 : baseRange(end)+1;
    db = struct( );
    db.x = Series(extdRange, @rand);
    db.m = Series(extdRange, @rand);
    db.a = Series(baseRange, @rand);
    db.b = Series(baseRange, @rand);
    db.c = Series(baseRange, @rand);
    db.d = Series(extdRange, @rand);
    db.y = Series(extdRange, @rand);
    db.n = Series(extdRange, @rand);
    db.res_x = Series(extdRange(5:10), @rand);
    db.res_m = Series(extdRange(5:10), @rand);
    testCase.TestData.BaseRange = baseRange;
    testCase.TestData.ExtendedRange = extdRange;
    testCase.TestData.Databank = db;

%% Test YXE Single
    m = testCase.TestData.Model1;
    db = testCase.TestData.Databank;
    baseRange = testCase.TestData.BaseRange;
    extdRange = testCase.TestData.ExtendedRange;
    numExtendedPeriods = numel(extdRange);
    lhsRequired = true; 
    dataBlock = getDataBlock(m, db, baseRange, lhsRequired, "");
    baseRangeColumns = dataBlock.BaseRangeColumns;
    m = runtime(m, dataBlock, "");
    controls = struct( );
    [plain, lhs, rhs, res] = createModelData(m, dataBlock, controls);
    exp_y = nan(1, numExtendedPeriods);
    exp_y(baseRangeColumns) = log(db.x(baseRange));
    assertEqual(testCase, lhs, exp_y);

    exp_rhs = nan(5, numExtendedPeriods);
    exp_rhs(1, baseRangeColumns) = db.a(baseRange);
    exp_rhs(2, baseRangeColumns) = log(db.c(baseRange));
    exp_rhs(3, baseRangeColumns) = db.y(baseRange+1);
    exp_rhs(4, baseRangeColumns) = -1;
    exp_rhs(5, baseRangeColumns) = db.b(baseRange).*db.x(baseRange-1) + db.d(baseRange);
    assertEqual(testCase, rhs, exp_rhs);
    exp_res = nan(1, numExtendedPeriods);
    temp = db.res_x(baseRange);
    temp(isnan(temp)) = 0;
    exp_res(1, baseRangeColumns) = temp;
    assertEqual(testCase, res, exp_res);

    exp_plain = nan(7, numExtendedPeriods);
    exp_plain(1, :) = db.x(extdRange);
    exp_plain(2, :) = db.a(extdRange);
    exp_plain(3, :) = db.b(extdRange);
    exp_plain(4, :) = db.c(extdRange);
    exp_plain(5, :) = db.y(extdRange);
    exp_plain(6, :) = db.d(extdRange);
    exp_plain(7, :) = db.res_x(extdRange);
    assertEqual(testCase, plain, exp_plain);


%% Test YXE System One
    m1 = testCase.TestData.Model1;
    m2 = testCase.TestData.Model2;
    m = [m1, m2];
    db = testCase.TestData.Databank;
    baseRange = testCase.TestData.BaseRange;
    extdRange = testCase.TestData.ExtendedRange;
    numExtendedPeriods = numel(extdRange);
    lhsRequired = true; 
    dataBlock = getDataBlock(m, db, baseRange, lhsRequired, "");
    baseRangeColumns = dataBlock.BaseRangeColumns;
    m(1) = runtime(m(1), dataBlock, "");
    controls = struct( );
    [plain, lhs, rhs, res] = createModelData(m(1), dataBlock, controls);
    exp_y = nan(1, numExtendedPeriods);
    exp_y(baseRangeColumns) = log(db.x(baseRange));
    assertEqual(testCase, lhs, exp_y);

    exp_rhs = nan(5, numExtendedPeriods);
    exp_rhs(1, baseRangeColumns) = db.a(baseRange);
    exp_rhs(2, baseRangeColumns) = log(db.c(baseRange));
    exp_rhs(3, baseRangeColumns) = db.y(baseRange+1);
    exp_rhs(4, baseRangeColumns) = -1;
    exp_rhs(5, baseRangeColumns) = db.b(baseRange).*db.x(baseRange-1) + db.d(baseRange);
    assertEqual(testCase, rhs, exp_rhs);

    exp_res = nan(1, numExtendedPeriods);
    temp = db.res_x(baseRange);
    temp(isnan(temp)) = 0;
    exp_res(1, baseRangeColumns) = temp;
    assertEqual(testCase, res, exp_res);

    exp_plain = nan(7, numExtendedPeriods);
    exp_plain(1, :) = db.x(extdRange);
    exp_plain(2, :) = db.a(extdRange);
    exp_plain(3, :) = db.b(extdRange);
    exp_plain(4, :) = db.c(extdRange);
    exp_plain(5, :) = db.y(extdRange);
    exp_plain(6, :) = db.d(extdRange);
    exp_plain(7, :) = db.res_x(extdRange);
    assertEqual(testCase, plain, exp_plain);


%% Test YXE System Two
    m1 = testCase.TestData.Model1;
    m2 = testCase.TestData.Model2;
    m = [m1, m2];
    db = testCase.TestData.Databank;
    baseRange = testCase.TestData.BaseRange;
    extdRange = testCase.TestData.ExtendedRange;
    numExtendedPeriods = numel(extdRange);
    lhsRequired = true; 
    dataBlock = getDataBlock(m, db, baseRange, lhsRequired, "");
    baseRangeColumns = dataBlock.BaseRangeColumns;
    m(2) = runtime(m(2), dataBlock, "");
    controls = struct( );
    [plain, lhs, rhs, res] = createModelData(m(2), dataBlock, controls);
    exp_y = nan(1, numExtendedPeriods);
    exp_y(baseRangeColumns) = log(db.m(baseRange));
    assertEqual(testCase, lhs, exp_y);

    exp_rhs = nan(5, numExtendedPeriods);
    exp_rhs(1, baseRangeColumns) = db.a(baseRange);
    exp_rhs(2, baseRangeColumns) = log(db.c(baseRange));
    exp_rhs(3, baseRangeColumns) = db.n(baseRange+1);
    exp_rhs(4, baseRangeColumns) = -1;
    exp_rhs(5, baseRangeColumns) = db.b(baseRange).*db.m(baseRange-1) + db.d(baseRange);
    assertEqual(testCase, rhs, exp_rhs);

    exp_res = nan(1, numExtendedPeriods);
    temp = db.res_m(baseRange);
    temp(isnan(temp)) = 0;
    exp_res(1, baseRangeColumns) = temp;
    assertEqual(testCase, res, exp_res);

    exp_plain = nan(7, numExtendedPeriods);
    exp_plain(1, :) = db.m(extdRange);
    exp_plain(2, :) = db.a(extdRange);
    exp_plain(3, :) = db.b(extdRange);
    exp_plain(4, :) = db.c(extdRange);
    exp_plain(5, :) = db.n(extdRange);
    exp_plain(6, :) = db.d(extdRange);
    exp_plain(7, :) = db.res_m(extdRange);
    assertEqual(testCase, plain, exp_plain);

##### SOURCE END #####
%}

