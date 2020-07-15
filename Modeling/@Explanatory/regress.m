% regress  Estimate parameters of regression terms in Explanatory object or array
%{
%% Syntax
%--------------------------------------------------------------------------
%
%     [expy, outputDb] = regress(expy, inputDb, fittedRange, ...)
%
%
%% Input Arguments
%--------------------------------------------------------------------------
%
% __`expy`__ [ Explanatory ]
%
%     Explanatory object or array whose parameters (associated with
%     regression terms) will be estimated by running a single-equation
%     linear regression; only those parameters that have the corresonding
%     element in `.Fixed` set to `NaN` will be estimated.k
%
%
% __`inputDb`__ [ struct | Dictionary ]
%
%     Input databank from which the time series for each variable in the
%     Explanatory object or array will be retrieved.
%    
%
% __`fittedRange`__ [ DateWrapper ]
%
%     Date range on which the linear regression(s) will be fitted; this
%     range does not include the pre-sample initial condition if there are
%     lags in the Explanatory object or array.
%
% 
%% Output Arguments
%--------------------------------------------------------------------------
%
% __`expy`__ [ Explanatory ]
% 
%     Output Explanatory object or array with the parameters estimated.
%
%
% __`outputDb`__ [ struct | Dictionary ]
%
%     Output databank inclusive of the fitted values and residuals (whose
%     names will be created using the `.FittedNamePattern` and
%     `.ResidualNamePattern`.
%    
%
%% Options
%--------------------------------------------------------------------------
%
% __`AppendInput=false`__ [ `true` | `false` ]
%
%     Append post-sample data from the `inputDb` to the `outputDb`.
%
%
% __`MissingObservations='Warning'` [ `'Error'` | `'Warning'` | `'Silent'` ]
%
%     Action taken when some within-sample observations are missing:
%     `'Error'` means an error message will be thrown; `'Warning'` means
%     these observations will be excluded from the estimation sample with a
%     warning; `'Silent'` means these observations will be excluded from
%     the estimation sample silently.
%
%
% __`PrependInput=false`__ [ `true` | `false` ]
%
%     Prepend pre-sample data from the `inputDb` to the `outputDb`.
%
%
%% Description
%--------------------------------------------------------------------------
%
%
%% Example
%--------------------------------------------------------------------------
%
% Create an Explanatory object from a string inclusive of three regression
% terms, i.e. additive terms preceded by `+@*` or `-@*`:
%
%     expy0 = Explanatory.fromString("difflog(x) = @ + @*difflog(x{-1}) + @*log(z)");
%     expy0.Parameters
% 
% Assign some parameters to the three regression terms:
%
%     expy0.Parameters = [0.002, 0.8, 1];
% 
% 
% Simulate the equation dynamically, using random shocks (names `'res_x'`
% by default) and random observations for `z`:
%
%     rng(981);
%     d0 = struct( );
%     d0.x = Series(qq(2020,1), ones(40,1));
%     d0.z = Series(qq(2020,1), exp(randn(40, 1)/10));
%     d0.res_x = Series(qq(2020,1), randn(40, 1)/50);
% 
%     d1 = simulate(expy0, d0, qq(2021,1):qq(2029,4));
% 
% Estimate the parameters using the simulated data, and compare the
% parameter estimates and the estimated residuals with their "true" values:
%
%     [expy2, d2] = regress(expy0, d1, qq(2021,1):qq(2029,4));
%     [ expy0.Parameters; expy2.Parameters ]
%     plot([d0.res_x, d2.res_x]);
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [this, outputDb, info] = regress(this, inputDb, fittedRange, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory.regress');

    addRequired(pp, 'explanatoryEquation', @(x) isa(x, 'Explanatory'));
    addRequired(pp, 'inputDb', @validate.databank);
    addRequired(pp, 'fittedRange', @DateWrapper.validateRangeInput);

    addParameter(pp, 'AddToDatabank', @auto, @(x) isequal(x, @auto) || isequal(x, [ ]) || validate.databank(x));
    addParameter(pp, {'AppendPostsample', 'PrependInput'}, false, @validate.logicalScalar);
    addParameter(pp, {'AppendPresample', 'AppendInput'}, false, @validate.logicalScalar);
    addParameter(pp, 'OutputType', 'struct', @validate.databankType);
    addParameter(pp, "MissingObservations", @auto, @(x) isequal(x, @auto) || validate.anyString(x, ["Error", "Warning", "Silent"]));
    addParameter(pp, 'ResidualsOnly', false, @validate.logicalScalar);
end
%)
opt = parse(pp, this, inputDb, fittedRange, varargin{:});
[fittedRange, opt.MissingObservations] = locallyResolveRange(this, inputDb, fittedRange, opt.MissingObservations);

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
dataBlock = getDataBlock(this, inputDb, fittedRange, lhsRequired, context);


%
% Create struct with controls
%
controls = assignControls(this, inputDb);


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


% /////////////////////////////////////////////////////////////////////////
inxColumns = cell(numEquations, numPages);
inxToEstimate = ~[this.IsIdentity];
for q = find(inxToEstimate)
    this__ = this(q);

    [plainData, lhs, rhs] = createModelData(this__, dataBlock, controls);

    if opt.ResidualsOnly
        fixed = this__.Parameters;
    else
        fixed = this__.Fixed;
    end
    
    %
    % Estimate parameter variants from individual data pages
    %
    res__ = nan(size(lhs));
    for v = 1 : numPages
        inxColumns__ = dataBlock.InxBaseRange;
        inxFiniteColumns = all(isfinite([rhs(:, :, v); lhs(:, :, v)]), 1);
        inxMissingColumns(q, :, v) = inxColumns__ & ~inxFiniteColumns;
        if strcmpi(opt.MissingObservations, 'Warning') || strcmpi(opt.MissingObservations, 'Silent')
            inxColumns__ = inxColumns__ & inxFiniteColumns;
        elseif any(inxMissingColumns(q, :, v))
            continue
        end
        if ~any(inxColumns__)
            reportEmptyData = [reportEmptyData, this__.LhsName];
            continue
        end

        lhs__ = lhs(:, inxColumns__, v);
        rhs__ = rhs(:, inxColumns__, v);
        [parameters, varResiduals, covParameters] = locallyLeastSquares(lhs__, rhs__, fixed(1, :, min(v, end)));

        this__.Parameters(1, :, v) = parameters;
        fitted(q, inxColumns__, v) = parameters*rhs__;
        res__(:, inxColumns__, v) = lhs(:, inxColumns__, v) - fitted(q, inxColumns__, v);
        this__.Statistics.VarResiduals(:, :, v) = varResiduals;
        this__.Statistics.CovParameters(:, :, v) = covParameters;
        inxColumns{q, v} = inxColumns__;
    end
    plainData = updateResidualsInPlainData(this__, plainData, res__, inxColumns__);

    %
    % Update residuals in dataBlock from plainData
    %
    updateDataBlock(this__, dataBlock, plainData);

    %
    % Update statistics in the Explanatory array
    %
    this(q) = this__;
end
% /////////////////////////////////////////////////////////////////////////


if ~isempty(reportEmptyData)
    hereReportEmptyData( );
end

if ~strcmpi(opt.MissingObservations, 'Silent') && nnz(inxMissingColumns)>0
    hereReportMissing( );
end

if storeToDatabank
    namesToInclude = [this.ResidualName];
    outputDb = createOutputDatabank( ...
        this, inputDb, dataBlock ...
        , namesToInclude, fitted(inxToEstimate, :, :), opt ...
    );
end

%
% Reset runtime information
%
this = runtime(this);

if nargout>=3
    info = herePopulateOutputInfo( );
end

return

    function hereReportEmptyData( )
        %(
        reportEmptyData = cellstr(reportEmptyData);
        thisWarning = [ 
            "Explanatory:EmptyRegressionData"
            "Explanatory[""%s""] cannot be regressed because "
            "there is not a single period of observations available." 
        ];
        throw(exception.Base(thisWarning, 'warning'), reportEmptyData{:});
        %)
    end%


    function hereReportMissing( )
        %(
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
        %)
    end%


    function info = herePopulateOutputInfo( )
        %(
        info = struct( );
        info.FittedPeriods = cell(size(inxColumns));
        extendedRange = double(dataBlock.ExtendedRange);
        for i = 1 : numel(inxColumns)
            info.FittedPeriods{i} = DateWrapper(extendedRange(inxColumns{i}));
        end
        %)
    end%
end%

%
% Local Functions
%

function [fittedRange, missingObservations] = locallyResolveRange(this, inputDb, fittedRange, missingObservations)
    %(
    fittedRange = double(fittedRange);
    from = fittedRange(1);
    to = fittedRange(end);
    defaultMissingObservations = "Warning";
    if isinf(from) || isinf(to)
        [from, to] = databank.backend.resolveRange(inputDb, collectAllNames(this), from, to);
        defaultMissingObservations = "Silent";
    end
    if isequal(missingObservations, @auto)
        missingObservations = defaultMissingObservations;
    end
    fittedRange = [from, to];
    %)
end%

function [parameters, varResiduals, covParameters] = locallyLeastSquares(y, X, fixed)
    %(
    numParameters = numel(fixed);
    parameters = fixed;
    covParameters = zeros(numParameters, numParameters);
    inxFixed = ~isnan(fixed);
    if any(inxFixed)
        y = y - fixed(inxFixed)*X(inxFixed, :);
        X = X(~inxFixed, :);
    end
    [beta, ~, varResiduals, covBeta] = lscov(transpose(X), transpose(y));
    parameters(~inxFixed) = transpose(beta);
    covParameters(~inxFixed, ~inxFixed) = covBeta;
    %)
end%



%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/regressUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once
    m1 = Explanatory.fromString('x = @ + @*x{-1} + @*y');
    m2 = Explanatory.fromString('a = @ + @*a{-1} + @*x');
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


%% Test ARX
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    y = db1.x(baseRange);
    X = [ones(40, 1), db1.x{-1}(baseRange), db1.y(baseRange)];
    exp_parameters = transpose(X\y);
    assertEqual(testCase, est1.Parameters, exp_parameters, 'AbsTol', 1e-12);
    assertEqual(testCase, isfield(outputDb, m1.ResidualName), true);


%% Test Resimulate 
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    simDb = simulate(est1, outputDb, baseRange);
    assertEqual(testCase, db1.x(baseRange), simDb.x(baseRange), 'AbsTol', 1e-12);



%% Test Resimulate Prepend
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    simDb = simulate(est1, outputDb, baseRange, 'PrependInput=', true);
    startDate = db1.x.Start;
    range = db1.x.Start : baseRange(end);
    assertEqual(testCase, db1.x(range), simDb.x(range), 'AbsTol', 1e-12);


%% Test Resimulate Append
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    simDb = simulate(est1, outputDb, baseRange, 'AppendInput=', true);
    range = baseRange(1)-1 : db1.x.End;
    assertEqual(testCase, db1.x(range), simDb.x(range), 'AbsTol', 1e-12);


%% Test ARX System
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


%% Test ARX System Variants
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

##### SOURCE END #####
%}

