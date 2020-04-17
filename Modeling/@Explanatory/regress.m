function varargout = regress(this, inputDatabank, fittedRange, varargin)
% regress  Estimate regression parameters of Explanatory 
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


persistent parser
if isempty(parser)
    parser = extend.InputParser('Explanatory.regress');
    %
    % Required arguments
    %
    addRequired(parser, 'explanatoryEquation', @(x) isa(x, 'Explanatory'));
    addRequired(parser, 'inputDatabank', @validate.databank);
    addRequired(parser, 'fittedRange', @DateWrapper.validateProperRangeInput);
    %
    % Options
    % 
    addParameter(parser, 'AddToDatabank', @auto, @(x) isequal(x, @auto) || isequal(x, [ ]) || validate.databank(x));
    addParameter(parser, 'AppendPostsample', false, @validate.logicalScalar);
    addParameter(parser, 'AppendPresample', false, @validate.logicalScalar);
    addParameter(parser, 'OutputType', 'struct', @validate.databankType);
    addParameter(parser, 'MissingObservations', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
    addParameter(parser, 'FixParameters', false, @validate.logicalScalar);
end
parse(parser, this, inputDatabank, fittedRange, varargin{:});
opt = parser.Options;

storeToDatabank = nargout>=2;

%--------------------------------------------------------------------------

fittedRange = double(fittedRange);
numEquations = numel(this);

%
% Create a DataBlock for all variables across all models; LHS variables are
% needed even if they do not appear on the RHS 
%
lhsRequired = true;
context = "for " + this(1).Context + " estimation";
dataBlock = getDataBlock(this, inputDatabank, fittedRange, lhsRequired, context);


%
% Create struct with controls
%
controls = assignControls(this, inputDatabank);


numExtendedPeriods = dataBlock.NumOfExtendedPeriods;
numPages = dataBlock.NumOfPages;
fitted = nan(numEquations, numExtendedPeriods, numPages);
inxMissingColumns = false(numEquations, numExtendedPeriods, numPages);
reportEmptyData = string.empty(1, 0);

%
% Prepare runtime information
%
this = runtime(this, dataBlock, "regress");

%
% Preallocate space for parameters and statistics, reset all to NaN
%
resetToNaN = true;
this = alter(this, numPages, resetToNaN);


%//////////////////////////////////////////////////////////////////////////
inxToEstimate = ~[this.IsIdentity];
for q = find(inxToEstimate)
    this__ = this(q);

    [plainData, lhs, rhs] = createModelData(this__, dataBlock, controls);

    if opt.FixParameters
        fixed = this__.Parameters;
    else
        fixed = [this__.ExplanatoryTerms.Fixed];
    end
    
    %
    % Estimate parameter variants from individual data pages
    %
    for v = 1 : numPages
        inxColumns = dataBlock.InxBaseRange;
        inxFiniteColumns = all(isfinite([rhs(:, :, v); lhs(:, :, v)]), 1);
        inxMissingColumns(q, :, v) = inxColumns & ~inxFiniteColumns;
        if strcmpi(opt.MissingObservations, 'Warning') || strcmpi(opt.MissingObservations, 'Silent')
            inxColumns = inxColumns & inxFiniteColumns;
        elseif any(inxMissingColumns(q, :, v))
            continue
        end
        if ~any(inxColumns)
            reportEmptyData = [reportEmptyData, this__.LhsName];
            continue
        end

        lhs__ = lhs(:, inxColumns, v);
        rhs__ = rhs(:, inxColumns, v);
        [parameters, varResiduals, covBeta] = hereGLSq(lhs__, rhs__, fixed(1, :, min(v, end)));

        this__.Parameters(1, :, v) = parameters;
        fitted(q, inxColumns, v) = parameters*rhs__;
        res__ = lhs(:, inxColumns, v) - fitted(q, inxColumns, v);
        plainData(end, inxColumns, v) = res__;
        this__.Statistics.VarResiduals(:, :, v) = varResiduals;
        this__.Statistics.CovParameters(:, :, v) = covBeta;
    end

    %
    % Update residuals in dataBlock from plainData
    %
    updateDataBlock(this__, dataBlock, plainData);

    %
    % Update statistics in the Explanatory array
    %
    this(q) = this__;
end
%//////////////////////////////////////////////////////////////////////////


if ~isempty(reportEmptyData)
    hereReportEmptyData( );
end

if ~strcmpi(opt.MissingObservations, 'Silent') && nnz(inxMissingColumns)>0
    hereReportMissing( );
end

if storeToDatabank
    namesToInclude = [this.ResidualName];
    outputDb = createOutputDatabank( ...
        this, inputDatabank, dataBlock ...
        , namesToInclude, fitted(inxToEstimate, :, :), opt ...
    );
end

%
% Reset runtime information
%
this = runtime(this);


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout = {this, outputDb};
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

return


    function hereReportEmptyData( )
        reportEmptyData = cellstr(reportEmptyData);
        thisWarning = [ 
            "Explanatory:EmptyRegressionData"
            "Explanatory[""%s""] cannot be regressed because "
            "there is not a single period of observations available." 
        ];
        throw(exception.Base(thisWarning, 'warning'), reportEmptyData{:});
    end%


    function hereReportMissing( )
        if strcmpi(opt.MissingObservations, 'Warning')
            action = 'adjusted to exclude';
        else
            action = 'contain';
        end
        report = cell.empty(1, 0);
        for qq = 1 : numEquations
            if nnz(inxMissingColumns(qq, :, :))==0
                continue
            end
            report = [report, DateWrapper.reportMissingPeriodsAndPages(dataBlock.ExtendedRange, inxMissingColumns, this.LhsName)];
        end
        thisWarning  = [ 
            "Explanatory:MissingObservationInRegressionRange"
            "Explanatory[""%s""] regression data " + action + " "
            "NaN or Inf observations [Variant|Page:%g]: %s" 
        ];
        throw(exception.Base(thisWarning, opt.MissingObservations), report{:});
    end%
end%


%
% Local Functions
%


function [parameters, varResiduals, covBeta] = hereGLSq(y, X, fixed)
    numParameters = numel(fixed);
    parameters = fixed;
    covBeta = zeros(numParameters, numParameters);
    inxFixed = ~isnan(fixed);
    if any(inxFixed)
        y = y - fixed(inxFixed)*X(inxFixed, :);
        X = X(~inxFixed, :);
    end
    [beta, ~, varResiduals, covBeta] = lscov(transpose(X), transpose(y));
    parameters(~inxFixed) = transpose(beta);
    covBeta(~inxFixed, ~inxFixed) = covBeta;
end%



%
% Unit Tests 
%
%(
function tests = unitTests( )
    tests = functiontests({ 
        @setupOnce 
        @arxTest  
        @resimulateTest
        @resimulatePrependTest
        @resimulateAppendTest
        @arxSystemTest
        @arxSystemVariantsTest 
    });
    tests = reshape(tests, [ ], 1);
end%


function setupOnce(testCase)
    m1 = Explanatory.fromString('x = ? + ?*x{-1} + ?*y');
    m2 = Explanatory.fromString('a = ? + ?*a{-1} + ?*x');
    startDate = qq(2001,1);
    endDate = qq(2010, 4);
    baseRange = startDate:endDate;
    db1 = struct( );
    db1.x = Series(startDate-10:endDate+10, cumsum(randn(60,1)));
    db1.a = Series(startDate-1:endDate, cumsum(randn(41,1)));
    db1.y = Series(startDate:endDate, cumsum(randn(40,1)));
    db2 = struct( );
    db2.x = Series(startDate-1:endDate, cumsum(randn(41,3)));
    db2.a = Series(startDate-1:endDate, cumsum(randn(41,1)));
    db2.y = Series(startDate:endDate, cumsum(randn(40,1)));
    testCase.TestData.Model1 = m1;
    testCase.TestData.Model2 = m2;
    testCase.TestData.Databank1 = db1;
    testCase.TestData.Databank2 = db2;
    testCase.TestData.BaseRange = baseRange;
end%


function arxTest(testCase)
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    y = db1.x(baseRange);
    X = [ones(40, 1), db1.x{-1}(baseRange), db1.y(baseRange)];
    exp_parameters = transpose(X\y);
    assertEqual(testCase, est1.Parameters, exp_parameters, 'AbsTol', 1e-12);
    assertEqual(testCase, isfield(outputDb, m1.ResidualName), true);
end%


function resimulateTest(testCase)
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    simDb = simulate(est1, outputDb, baseRange);
    assertEqual(testCase, db1.x(baseRange), simDb.x(baseRange), 'AbsTol', 1e-12);
end%


function resimulatePrependTest(testCase)
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    simDb = simulate(est1, outputDb, baseRange, 'PrependInput=', true);
    startDate = db1.x.Start;
    range = db1.x.Start : baseRange(end);
    assertEqual(testCase, db1.x(range), simDb.x(range), 'AbsTol', 1e-12);
end%


function resimulateAppendTest(testCase)
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    simDb = simulate(est1, outputDb, baseRange, 'AppendInput=', true);
    range = baseRange(1)-1 : db1.x.End;
    assertEqual(testCase, db1.x(range), simDb.x(range), 'AbsTol', 1e-12);
end%


function arxSystemTest(testCase)
    m1 = testCase.TestData.Model1;
    m2 = testCase.TestData.Model2;
    m = [m1, m2];
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est, outputDb] = regress(m, db1, baseRange);
    y = db1.x(baseRange);
    X = [ones(40, 1), db1.x{-1}(baseRange), db1.y(baseRange)];
    exp_parameters = transpose(X\y);
    assertEqual(testCase, est(1).Parameters, exp_parameters, 'AbsTol', 1e-12);
    y = db1.a(baseRange);
    X = [ones(40, 1), db1.a{-1}(baseRange), db1.x(baseRange)];
    exp_parameters = transpose(X\y);
    assertEqual(testCase, est(2).Parameters, exp_parameters, 'AbsTol', 1e-12);
    assertEqual(testCase, isfield(outputDb, m1.ResidualName), true);
    assertEqual(testCase, isfield(outputDb, m2.ResidualName), true);
end%


function arxSystemVariantsTest(testCase)
    m1 = testCase.TestData.Model1;
    m2 = testCase.TestData.Model2;
    m = [m1, m2];
    db2 = testCase.TestData.Databank2;
    baseRange = testCase.TestData.BaseRange;

    [est, outputDb] = regress(m, db2, baseRange);

    exp_parameters = nan(1, 3, 3);
    for i = 1 : 3
        y = db2.x(baseRange, i);
        X = [ones(40, 1), db2.x{-1}(baseRange, i), db2.y(baseRange)];
        exp_parameters(:, :, i) = transpose(X\y);
    end
    assertEqual(testCase, est(1).Parameters, exp_parameters, 'AbsTol', 1e-12);

    exp_parameters = nan(1, 3, 3);
    for i = 1 : 3
        y = db2.a(baseRange);
        X = [ones(40, 1), db2.a{-1}(baseRange), db2.x(baseRange, i)];
        exp_parameters(:, :, i) = transpose(X\y);
    end
    assertEqual(testCase, est(2).Parameters, exp_parameters, 'AbsTol', 1e-12);
end%
%)

