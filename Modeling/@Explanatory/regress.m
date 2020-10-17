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
% Simulate the equation period by period, using random shocks (names `'res_x'`
% by default) and random observations for `z`:
%
%     rng(981);
%     d0 = struct();
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

% >=R2019b
%{
function [this, outputDb, info] = regress(this, inputDb, fittedRange, opt)

arguments
    this Explanatory
    inputDb (1, 1) {validate.databank}
    fittedRange {validate.rangeInput}

    opt.AddToDatabank = @auto
    opt.BlackoutBefore {Explanatory.validateBlackout(opt.BlackoutBefore, this)} = -Inf
    opt.BlackoutAfter {Explanatory.validateBlackout(opt.BlackoutAfter, this)} = Inf
    opt.PrependInput (1, 1) {mustBeA(opt.PrependInput, "logical")} = false
    opt.AppendInput (1, 1) {mustBeA(opt.AppendInput, "logical")} = false
    opt.OutputType (1, 1) string {validate.databankType} = "struct"
    opt.MissingObservations = @auto
    opt.Optim = []
    opt.Progress (1, 1) {mustBeA(opt.Progress, "logical")} = false
    opt.ResidualsOnly (1, 1) {mustBeA(opt.ResidualsOnly, "logical")} = false
    opt.Journal = false
end

opt.AppendPresample = opt.PrependInput;
opt.AppendPostsample = opt.AppendInput;
%}
% >=R2019b

% <=R2019a
%(
function [this, outputDb, info] = regress(this, inputDb, fittedRange, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory.regress');

    addRequired(pp, 'explanatoryEquation', @(x) isa(x, 'Explanatory'));
    addRequired(pp, 'inputDb', @validate.databank);
    addRequired(pp, 'fittedRange', @DateWrapper.validateRangeInput);

    addParameter(pp, 'AddToDatabank', @auto, @(x) isequal(x, @auto) || isequal(x, []) || validate.databank(x));
    addParameter(pp, {'AppendPresample', 'PrependInput'}, false, @validate.logicalScalar);
    addParameter(pp, {'AppendPostsample', 'AppendInput'}, false, @validate.logicalScalar);
    addParameter(pp, "BlackoutBefore", -Inf, @Explanatory.validateBlackout);
    addParameter(pp, "BlackoutAfter", Inf, @Explanatory.validateBlackout);
    addParameter(pp, 'OutputType', 'struct', @validate.databankType);
    addParameter(pp, "MissingObservations", @auto, @(x) isequal(x, @auto) || validate.anyString(x, ["Error", "Warning", "Silent"]));
    addParameter(pp, "Optim", [], @(x) isempty(x) || isa(x, "optim.options.Lsqnonlin"));
    addParameter(pp, "Progress", false, @validate.logicalScalar);
    addParameter(pp, 'ResidualsOnly', false, @validate.logicalScalar);
    addParameter(pp, "Journal", false);
end
opt = parse(pp, this, inputDb, fittedRange, varargin{:});
%)
% <=R2019a

[fittedRange, opt.MissingObservations] = locallyResolveRange(this, inputDb, fittedRange, opt.MissingObservations);
opt.BlackoutBefore = Explanatory.resolveBlackout(opt.BlackoutBefore);
opt.BlackoutAfter = Explanatory.resolveBlackout(opt.BlackoutAfter);

storeToDatabank = nargout>=2;
journal = Journal(opt.Journal, "@Explanatory/regress");

%--------------------------------------------------------------------------

fittedRange = double(fittedRange);
numEquations = numel(this);

%
% Create a DataBlock for all variables across all models; LHS variables are
% needed even if they do not appear on the RHS 
%
lhsRequired = true;
context = "to run regress() on the " + this(1).Context + " object";
dataBlock = getDataBlock(this, inputDb, fittedRange, lhsRequired, context);


%
% Create struct with controls
%
controls = assignControls(this, inputDb);


numExtendedPeriods = dataBlock.NumExtendedPeriods;
numPages = dataBlock.NumPages;
fitted = nan(numEquations, numExtendedPeriods, numPages);
lhsTransform = nan(numEquations, numExtendedPeriods, numPages);
inxMissingColumns = false(numEquations, numExtendedPeriods, numPages);
reportEmptyData = string.empty(1, 0);
extdRange = double(dataBlock.ExtendedRange);


%
% Prepare runtime information
%
this = runtime(this, dataBlock, "regress");


%
% Preallocate space for parameters and statistics, reset all to NaN
%
inxColumns = cell(numEquations, numPages);
inxToEstimate = ~[this.IsIdentity];
this(inxToEstimate) = alter(this(inxToEstimate), numPages, NaN);


if opt.Progress
    progress = ProgressBar("@Explanatory/regress", nnz(inxToEstimate)*numPages);
end

exitFlags = nan(numEquations, numPages);

%==========================================================================
for q = find(inxToEstimate)
    this__ = this(q);
    indent(journal, this__.InputString);

    [lhs, rhs] = createData4Regress(this__, dataBlock, controls);

    if opt.ResidualsOnly
        fixed = this__.Parameters;
    else
        fixed = this__.Fixed;
    end
    residualModel = this__.ResidualModel;
    
    %
    % Estimate parameter variants from individual data pages
    %
    res = nan(size(lhs));
    for v = 1 : numPages
        fixed__ = fixed(:, :, min(v, end));
        indent(journal, "Variant|Page:" + string(v));

        %
        % Extract data for page v, black out observations
        %
        lhs__ = lhs(:, :, min(v, end));
        rhs__ = rhs(:, :, min(v, end));
        inxColumns__ = dataBlock.InxBaseRange;
        [lhs__, rhs__, inxColumns__] = locallyBlackout( ...
            lhs__, rhs__, inxColumns__, extdRange ...
            , opt.BlackoutBefore(min(q,end)), opt.BlackoutAfter(min(q,end)) ...
            , journal ...
        );

        %
        % Find missing within-sample observations
        %
        inxFiniteColumns__ = all(isfinite([rhs__; lhs__]), 1);
        inxMissingColumns(q, :, v) = inxColumns__ & ~inxFiniteColumns__;
        if startsWith(opt.MissingObservations, ["warning", "silent"], "ignoreCase", true)
            inxColumns__ = inxColumns__ & inxFiniteColumns__;
        elseif any(inxMissingColumns(q, :, v))
            continue
        end

        if journal.IsActive
            first__ = dater.toDefaultString(extdRange(find(inxColumns__, 1, "first")));
            last__ = dater.toDefaultString(extdRange(find(inxColumns__, 1, "last")));
            write(journal, "Fitted Range " + first__ + ":" + last__);
        end

        %
        % Extract within-sample non-missing observations only
        %
        lhs__ = lhs__(:, inxColumns__);
        rhs__ = rhs__(:, inxColumns__);
        if ~any(inxColumns__)
            reportEmptyData = [reportEmptyData, this__.LhsName];
            continue
        end
        numObservations__ = nnz(inxColumns__);

        if isa(residualModel, "ParameterizedArmani") && residualModel.NumParameters>0
            indent(journal, "Residual Model");
            [gamma__, exitFlag__] = locallyEstimateResidualModel(lhs__, rhs__, fixed__, residualModel, opt.Optim);
            residualModel.Parameters(1, :, v) = gamma__;
            residualModel = update(residualModel, gamma__);
            exitFlags(q, v) = exitFlag__;
            write(journal, "ExitFlag " + string(exitFlag__));
            write(journal, "Parameters " + join(string(gamma__)));
            deindent(journal);
        end

        [parameters__, varResiduals__, covParameters__, fitted__, res__, inxFixed__] ...
            = locallyLeastSquares(lhs__, rhs__, fixed__, residualModel);
        if any(~inxFixed__)
            write(journal, "Parameters " + join(string(parameters__(~inxFixed__))));
        end

        this__.Parameters(1, :, v) = parameters__;
        fitted(q, inxColumns__, v) = fitted__;
        lhsTransform(q, inxColumns__, v) = lhs__;
        res(:, inxColumns__, v) = res__;
        this__.Statistics.VarResiduals(:, :, v) = varResiduals__;
        this__.Statistics.CovParameters(:, :, v) = covParameters__;
        inxColumns{q, v} = inxColumns__;
        if opt.Progress
            increment(progress);
        end
        deindent(journal);
    end

    %
    % Update ResidualModel parameters
    %
    this__.ResidualModel = residualModel;

    %
    % Update residuals in dataBlock
    %
    updateDataBlock(this__, dataBlock, [], res);

    %
    % Update Parameters, Statistics and ResidualModel
    %
    this(q) = this__;
    deindent(journal);
end
%==========================================================================


if ~isempty(reportEmptyData)
    hereReportEmptyData();
end

if any(~isnan(exitFlags) & exitFlags<=0)
    hereReportFailedResidualModels();
end


if nnz(inxMissingColumns)>0
    if startsWith(opt.MissingObservations, "silent", "ignoreCase", true)
        % Do nothing
    else
        hereReportMissing();
    end
end


if storeToDatabank
    namesToInclude = [this(:).ResidualName];
    outputDb = createOutputDatabank( ...
        this, inputDb, dataBlock ...
        , namesToInclude ...
        , fitted(inxToEstimate, :, :) ...
        , lhsTransform(inxToEstimate, :, :) ...
        , opt ...
    );
end

%
% Reset runtime information
%
this = runtime(this);

if nargout>=3
    info = herePopulateOutputInfo();
end

return

    function hereReportEmptyData()
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


    function hereReportFailedResidualModels()
        %(
        lhsNames = collectAllLhsNames(this);
        [q, v] = find(~isnan(exitFlags) & exitFlags<=0);
        qv = sortrows([q, v], 1);
        temp = reshape([reshape(string(qv(:,2)), 1, []); reshape(lhsNames(qv(:,1)), 1, [])], [], 1);
        exception.error([
            "Explanatory:ResidualModelFailed"
            "ResidualModel for this LHS variable failed to converge [Parameter|Variant:%s]: %s "
        ], temp);
        %)
    end%


    function hereReportMissing()
        %(
        if startsWith(opt.MissingObservations, "warning", "ignoreCase", true)
            action = 'adjusted to exclude';
        else
            action = 'contain';
        end
        report = cell.empty(1, 0);
        for qq = 1 : numEquations
            if nnz(inxMissingColumns(qq, :, :))==0
                continue
            end
            addReport = dater.reportMissingPeriodsAndPages( ...
                extdRange, inxMissingColumns(qq, :, :), this(qq).LhsName ...
            );
            report = [report, addReport];
        end
        message  = [ 
            "Explanatory:MissingObservationInRegressionRange"
            "Explanatory[""%s""] regression data " + action + " "
            "NaN or Inf observations [Variant|Page:%g]: %s" 
        ];
        throw(exception.Base(message, opt.MissingObservations), report{:});
        %)
    end%


    function info = herePopulateOutputInfo()
        %(
        info = struct();
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


function [parameters, varResiduals, covParameters, fitted, res, inxFixed] = locallyLeastSquares(y, X, fixed, residualModel)
    %(
    numParameters = numel(fixed);
    numObservations = size(y, 2);
    parameters = fixed;
    inxFixed = ~isnan(fixed);
    y0 = y;
    X0 = X;
    if any(inxFixed)
        y = y - fixed(inxFixed)*X(inxFixed, :);
        X = X(~inxFixed, :);
    end
    covParameters = zeros(numParameters, numParameters);
    if any(~inxFixed)
        if isempty(residualModel)
            [beta, ~, ~, covBeta]  = lscov(transpose(X), transpose(y));
        else
            F = filterMatrix(residualModel, numObservations);
            [beta, ~, ~, covBeta]  = lscov(F\transpose(X), F\transpose(y));
        end
        parameters(~inxFixed) = transpose(beta);
        covParameters(~inxFixed, ~inxFixed) = covBeta;
    end
    fitted = parameters*X0;
    res = y - fitted;
    varResiduals = sum(res .* res, 2) / (numObservations - nnz(~inxFixed));
    %)
end%


function [gamma, exitFlag] = locallyEstimateResidualModel(y, X, fixed, rm, optim)
    %(
    persistent EMPTY_OPTIM
    if isempty(EMPTY_OPTIM)
        EMPTY_OPTIM = optimoptions("lsqnonlin", "display", "none");
    end
    numObservations = size(y, 2);
    inxFixed = ~isnan(fixed);
    y0 = y;
    X0 = X;
    if any(inxFixed)
        y = y - fixed(inxFixed)*X(inxFixed, :);
        X = X(~inxFixed, :);
    end
    yt = transpose(y);
    Xt = transpose(X);
    if isempty(optim)
        optim = EMPTY_OPTIM;
    end
    [gamma, ~, ~, exitFlag] = lsqnonlin(@hereObjectiveFunc, zeros(1, rm.NumParameters), [], [], optim);
    
    return
        function obj = hereObjectiveFunc(p)
            rm = update(rm, p);
            F = filterMatrix(rm, numObservations);
            Fyt = F\yt;
            if isempty(Xt)
                obj = Fyt;
            else
                FXt = F\Xt;
                beta = lscov(FXt, Fyt);
                obj = Fyt - FXt*beta;
            end
        end%
    %)
end%


function [lhs, rhs, inxColumns] = locallyBlackout(lhs, rhs, inxColumns, extdRange, before, after, journal)
    %(
    if isinf(before) && isinf(after)
        return
    end
    if ~isinf(before)
        pos = round(before - extdRange(1) + 1);
        if pos>1
            lhs(:, 1:pos-1) = NaN;
            rhs(:, 1:pos-1) = NaN;
            inxColumns(:, 1:pos-1) = false;
            if journal.IsActive
                write(journal, "Blackout before " + dater.toDefaultString(extdRange(pos)));
            end
        end
    end
    if ~isinf(after)
        pos = round(after - extdRange(1) + 1);
        if pos<size(lhs, 2)
            lhs(:, pos+1:end) = NaN;
            rhs(:, pos+1:end) = NaN;
            inxColumns(:, pos+1:end) = false;
            if journal.IsActive
                write(journal, "Blackout after " + dater.toDefaultString(extdRange(pos)));
            end
        end
    end
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
    db1 = struct();
    db1.x = Series(startDate-10:endDate+10, cumsum(randn(60,1)));
    db1.a = Series(startDate-1:endDate, cumsum(randn(41,1)));
    db1.y = Series(startDate:endDate, cumsum(randn(40,1)));
    db2 = struct();
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
    simDb = simulate(est1, outputDb, baseRange, 'prependInput', true);
    startDate = db1.x.Start;
    range = db1.x.Start : baseRange(end);
    assertEqual(testCase, db1.x(range), simDb.x(range), 'AbsTol', 1e-12);


%% Test Resimulate Append
    m1 = testCase.TestData.Model1;
    db1 = testCase.TestData.Databank1;
    baseRange = testCase.TestData.BaseRange;
    [est1, outputDb] = regress(m1, db1, baseRange);
    simDb = simulate(est1, outputDb, baseRange, 'appendInput', true);
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
    %
    [est, outputDb] = regress(m, db2, baseRange);
    %
    exp_parameters = nan(1, 3, 3);
    for i = 1 : 3
        y = db2.x(baseRange, i);
        X = [ones(40, 1), db2.x{-1}(baseRange, i), db2.y(baseRange)];
        exp_parameters(:, :, i) = transpose(X\y);
    end
    assertEqual(testCase, est(1).Parameters, exp_parameters, 'AbsTol', 1e-12);
    %
    exp_parameters = nan(1, 3, 3);
    for i = 1 : 3
        y = db2.a(baseRange);
        X = [ones(40, 1), db2.a{-1}(baseRange), db2.x(baseRange, i)];
        exp_parameters(:, :, i) = transpose(X\y);
    end
    assertEqual(testCase, est(2).Parameters, exp_parameters, 'AbsTol', 1e-12);

##### SOURCE END #####
%}

