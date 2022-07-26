% Type `web Explanatory/regress.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%(
function [this, outputDb, info] = regress(this, inputDb, fittedRange, opt)

arguments
    this Explanatory
    inputDb (1, 1) {validate.databank}
    fittedRange {validate.rangeInput}

    opt.AddToDatabank = @auto
    opt.BlackoutBefore {Explanatory.validateBlackout(opt.BlackoutBefore, this)} = -Inf
    opt.BlackoutAfter {Explanatory.validateBlackout(opt.BlackoutAfter, this)} = Inf
    opt.OutputType (1, 1) string {validate.databankType} = "struct"
    opt.MissingObservations = @auto
    opt.Optim = []
    opt.ResidualsOnly (1, 1) logical = false
    opt.Regularize (1, 1) double = 0
    opt.WhenEstimationFails (1, 1) string {mustBeMember(opt.WhenEstimationFails, ["error", "warning", "silent"])} = "error"
    opt.Progress (1, 1) logical = false
    opt.Journal = false
end
%)
% >=R2019b


% <=R2019a
%{
function [this, outputDb, info] = regress(this, inputDb, fittedRange, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "AddToDatabank", @auto);
    addParameter(ip, "BlackoutBefore", -Inf);
    addParameter(ip, "BlackoutAfter", Inf);
    addParameter(ip, "OutputType", "struct");
    addParameter(ip, "MissingObservations", @auto);
    addParameter(ip, "Optim", []);
    addParameter(ip, "ResidualsOnly", false);
    addParameter(ip, "Regularize", 0);
    addParameter(ip, "WhenEstimationFails", "error");
    addParameter(ip, "Progress", false);
    addParameter(ip, "Journal", false);
end
parse(ip, varargin{:});
opt = ip.Results;
%}
% <=R2019a


opt.AppendPresample = false;
opt.AppendPostsample = false;

[fittedRange, opt.MissingObservations] = local_resolveRange(this, inputDb, fittedRange, opt.MissingObservations);
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


numExtdPeriods = dataBlock.NumExtdPeriods;
numPages = dataBlock.NumPages;
fitted = nan(numEquations, numExtdPeriods, numPages);
lhsTransform = nan(numEquations, numExtdPeriods, numPages);
inxMissingColumns = false(numEquations, numExtdPeriods, numPages);
reportEmptyData = string.empty(1, 0);
extdRange = double(dataBlock.ExtendedRange);

%
% Prepare runtime information
%
this = runtime(this, dataBlock, "regress");


%
% Preallocate space for parameters and statistics, reset all to NaN unless
% this call is to evaluate residuals only
%
inxFitted = cell(numEquations, numPages);
inxToEstimate = ~[this.IsIdentity];
this = alter(this, numPages);
if ~opt.ResidualsOnly
    this(inxToEstimate) = reset(this(inxToEstimate));
end

if opt.Progress
    progress = ProgressBar("@Explanatory/regress", nnz(inxToEstimate)*numPages);
end

exitFlagsParameters = nan(numEquations, numPages);
exitFlagsResidualModels = nan(numEquations, numPages);

if journal.IsActive
    for q = find(~inxToEstimate)
        write(journal, "Skipping " + this(q).InputString);
    end
end

%==========================================================================
for q = find(inxToEstimate)
    this__ = this(q);
    indent(journal, "Estimating " + this__.InputString);

    if opt.ResidualsOnly
        fixed = this__.Parameters;
    else
        fixed = this__.Fixed;
    end

    residualModel = this__.ResidualModel;
    maxLag = this__.MaxLag;
    isLinear = this__.LinearStatus;
    residualName__ = this__.ResidualName;
    
    %
    % Estimate parameter variants from individual data pages
    %
    [lhs, rhs, subBlock] = createData4Regress(this__, dataBlock, controls);
    res = nan(size(lhs));
    for v = 1 : numPages
        fixed__ = fixed(:, :, min(v, end));
        indent(journal, "Variant|Page " + sprintf("%g", v));

        %
        % Extract data for page v, black out observations
        %
        lhs__ = lhs(:, :, min(v, end));
        rhs__ = rhs(:, :, min(v, end));
        subBlock__ = subBlock(:, :, min(v, end));

        %
        % Retain the LHS and RHS data on the entire regression range to
        % report fitted values and residuals after estimation
        %
        subBlock4Fit__ = subBlock__;

        inxBaseRange__ = dataBlock.InxBaseRange;
        [lhs__, rhs__, subBlock__, inxBaseRange__] ...
            = local_blackout( ...
                lhs__, rhs__, subBlock__ ...
                , maxLag, inxBaseRange__, extdRange ...
                , opt.BlackoutBefore(min(q,end)) ...
                , opt.BlackoutAfter(min(q,end)) ...
                , journal ...
            );


        if ~any(inxBaseRange__)
            reportEmptyData = [reportEmptyData, this__.LhsName];
            continue
        end


        if ~opt.ResidualsOnly && isa(residualModel, 'ParamArmani') && residualModel.NumParameters>0
            if ~isLinear
                exception.error([
                    "Explanatory:ArimaNonlinear"
                    "Join estimation of ARIMA errors and nonlinear regression parameters "
                    "not implemented yet. "
                ]);
            end
            indent(journal, "Residual Model");
            [gamma__, exitFlag__] ...
                = local_estimateResidualModel(lhs__, rhs__, fixed__, residualModel, inxBaseRange__, opt.Optim);
            residualModel.Parameters(1, :, v) = gamma__;
            residualModel = update(residualModel, gamma__);
            exitFlagsResidualModels(q, v) = exitFlag__;
            write(journal, "Exit flag " + sprintf("%g", exitFlag__));
            write(journal, "Parameters estimated " + sprintf("%g ", gamma__));
            deindent(journal);
        end

        
        %
        % Prepare filter matrix from the residual model
        %
        F = [];
        if ~isempty(residualModel) && ~residualModel.IsIdentity
            F = filterMatrix(residualModel, size(lhs__, 2));
        end

        %
        % Estimate parameters
        %
        [parameters__, varResiduals__, covParameters__, fitted__, res__, inxMissing__, exitFlag__, optimOutput__] ...
            = local_regress(this__, lhs__, rhs__, subBlock__, F, fixed__, inxBaseRange__, v, opt.Optim, opt.Regularize);

        exitFlagsParameters(q, v) = exitFlag__;

        if journal.IsActive && ~isempty(exitFlag__)
            write(journal, "Exit flag " + sprintf("%g", exitFlag__));
        end

        %
        % Report missing within-sample observations
        %
        inxMissingWithinBaseRange__ = inxBaseRange__ & inxMissing__;
        if any(inxMissingWithinBaseRange__) ...
                && startsWith(opt.MissingObservations, ["warning", "error"], "ignoreCase", true)
            here_reportMissing(inxMissingWithinBaseRange__, q);
        end

        if journal.IsActive
            [~, s] = dater.reportConsecutive(extdRange(inxBaseRange__ & ~inxMissingWithinBaseRange__));
            write(journal, "Dates fitted " + join(s, " "));
        end

        this__.Parameters(1, :, v) = parameters__;
        lhsTransform(q, :, v) = lhs__;
        this__.Statistics.VarResiduals(:, :, v) = varResiduals__;
        this__.Statistics.CovParameters(:, :, v) = covParameters__;
        this__.Statistics.NumPeriodsFitted(1, :, v) = nnz(~inxMissing__);
        this__.Statistics.ExitFlag(1, :, v) = exitFlag__;
        this__.Statistics.OptimOutput{1, :, v} = optimOutput__;
        inxFitted{q, v} = inxBaseRange__ & ~inxMissing__;

        %
        % Evaluate fitted values and residuals on the entire regression
        % range
        %
        [fitted, res] = here_evaluateFittedAndResiduals(fitted, res);


        if journal.IsActive
            %(
            temp = compose("%g", reshape(parameters__, 1, []));
            inxFixed__ = ~isnan(fixed__);
            if any(inxFixed__)
                temp(inxFixed__) = temp(inxFixed__) + "!";
            end
            write(journal, "Parameter values " + join(temp, " "));
            write(journal, "Residuals " + residualName__);
            %)
        end

        if opt.Progress
            increment(progress);
        end

        if journal.IsActive
            %(
            deindent(journal);
            %)
        end
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
    here_reportEmptyData();
end


%
% Handle failed exit flags
%

if lower(opt.WhenEstimationFails)=="silent"
    % Do nothing
else
    if any(~isnan(exitFlagsResidualModels) & exitFlagsResidualModels<=0) 
        local_reportFailedEstimation(exitFlagsResidualModels, this, "Residual model", opt.WhenEstimationFails)
    end
    if any(~isnan(exitFlagsParameters) & exitFlagsParameters<=0)
        local_reportFailedEstimation(exitFlagsParameters, this, "Parameter", opt.WhenEstimationFails);
    end
end


if nnz(inxMissingColumns)>0
    if startsWith(opt.MissingObservations, "silent", "ignoreCase", true)
        % Do nothing
    else
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
    info = here_populateOutputInfo();
end

return

    function [fitted, res] = here_evaluateFittedAndResiduals(fitted, res)
        %(
        inx = dataBlock.InxBaseRange;
        columnsBaseRange = find(inx);
        res0 = zeros(1, numExtdPeriods);
        fitted(q, columnsBaseRange, v) = this__.Simulate(subBlock4Fit__, res0, parameters__, columnsBaseRange, 1, []); 
        res(:, columnsBaseRange, v) = this__.EndogenizeResiduals(subBlock4Fit__, res0, parameters__, columnsBaseRange, 1, []);
        %)
    end%

    function here_reportEmptyData()
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

    function here_reportMissing(inxMissing, qq)
        %(
        if startsWith(opt.MissingObservations, "warning", "ignoreCase", true)
            action = 'adjusted to exclude';
        else
            action = 'contain';
        end
        report = dater.reportMissingPeriodsAndPages( ...
            extdRange, inxMissing(qq, :, :), this(qq).LhsName ...
        );
        message  = [ 
            "Explanatory:MissingObservationInRegressionRange"
            "Explanatory[""%s""] regression data " + action + " "
            "NaN or Inf observations [Variant|Page:%g]: %s" 
        ];
        throw(exception.Base(message, opt.MissingObservations), report);
        %)
    end%


    function info = here_populateOutputInfo()
        %(
        info = struct();
        info.FittedPeriods = cell(numEquations, numPages);
        extendedRange = double(dataBlock.ExtendedRange);
        for i = 1 : numel(inxFitted)
            info.FittedPeriods{i} = Dater(extendedRange(inxFitted{i}));
        end
        info.ExitFlagsResidualModels = exitFlagsResidualModels;
        info.ExitFlagsParameters = exitFlagsParameters;
        %)
    end%
end%

%
% Local Functions
%

function [fittedRange, missingObservations] = local_resolveRange(this, inputDb, fittedRange, missingObservations)
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


function [parameters, varResiduals, covParameters, fitted, res, inxMissing, exitFlag, optimOutput] ...
        = local_regress(this, y, X, subBlock, F, fixed, inxBaseRange, v, optimOptions, regularize)
    %(
    persistent DEFAULT_OPTIM_OPTIONS

    inxFixed = ~isnan(fixed);
    numColumns = size(y, 2);
    exitFlag = NaN;
    optimOutput = [];

    if this.LinearStatus
        %
        % Linear regression
        %

        % Adjust for within-sample missing observations

        inxMissing = any(~isfinite([y; X]), 1);
        y(:, inxMissing) = 0;
        X(:, inxMissing) = 0;


        if ~any(inxFixed)
            y1 = y;
            X1 = X;
        else
            y1 = y - fixed(inxFixed)*X(inxFixed, :);
            X1 = X(~inxFixed, :);
        end
        parameters = fixed;
        numParameters = numel(parameters);
        covParameters = zeros(numParameters);
        if any(~inxFixed)
            if isempty(F)
                [beta, ~, ~, covBeta]  = lscov(transpose(X1), transpose(y1));
            else
                [beta, ~, ~, covBeta]  = lscov(F\transpose(X1), F\transpose(y1));
            end
            parameters(~inxFixed) = transpose(beta);
            covParameters(~inxFixed, ~inxFixed) = covBeta;
        end
        fitted = parameters*X;
        fitted(:, inxMissing) = NaN;
        numParametersEstimated = nnz(~inxFixed);

    else
        %
        % Nonlinear (iterative) regression
        %
        if isempty(DEFAULT_OPTIM_OPTIONS)
            DEFAULT_OPTIM_OPTIONS = optimoptions("lsqnonlin", "display", "none");
        end

        if isempty(optimOptions)
            optimOptions = DEFAULT_OPTIM_OPTIONS;
        end

        endogenizeResidualsFunc = this.EndogenizeResiduals;
        simulateFunc = this.Simulate;

        columnsBaseRange = find(inxBaseRange);
        numParameters = this.NumParameters;
        inxToEstimate = ~inxFixed & this.IncParameters;
        numParametersEstimated = nnz(inxToEstimate);
        e = zeros(1, size(y, 2));


        % Evaluate endogenizeResidualsFunc for random parameters (to
        % minimize the change of singularity) once before to find
        % within-sample columns resulting in NaNs; these are replaced with
        % zeros when filtering the residuals

        inxMissing = [];
        zTest = rand(1, numParametersEstimated);
        [~, ~, objTest] = here_objectiveFunc(zTest);
        inxMissing = ~isfinite(objTest);


        % Initialize parameters to be estimated at zero, and call the
        % Optimization Toolbox

        z0 = zeros(1, numParametersEstimated);
        [z, ~, ~, exitFlag, optimOutput] = lsqnonlin(@here_objectiveFunc, z0, [], [], optimOptions);
        [~, parameters] = here_objectiveFunc(z);
        parameters(~inxToEstimate & ~inxFixed) = NaN;


        % Calculate fitted values using the simulate function

        fitted = nan(1, numColumns);
        fitted(:, columnsBaseRange) ...
            = simulateFunc(subBlock, e, parameters, columnsBaseRange, v, []); 
        fitted(:, inxMissing) = NaN;

        covParameters = nan(numParameters);
    end

    res = y - fitted;

    numPeriodsFitted = nnz(~inxMissing);
    varResiduals ...
        = sum(res(~inxMissing).^2, 2) / (numPeriodsFitted - numParametersEstimated);

    res(:, inxMissing) = NaN;
    y(:, inxMissing) = NaN;
    fitted(:, inxMissing) = NaN;

    return

        function [obj, p, objRegress, objRegularize] = here_objectiveFunc(z)
            p = zeros(1, numParameters);
            p(inxFixed) = fixed(inxFixed);
            p(inxToEstimate) = z;
            objRegress = zeros(1, numColumns);
            objRegress(:, columnsBaseRange) = endogenizeResidualsFunc(subBlock, e, p, columnsBaseRange, v, []);
            if ~isempty(inxMissing)
                objRegress(:, inxMissing) = 0;
                if ~isempty(F)
                    objRegress = transpose(F\transpose(objRegress));
                end
            end
            objRegularize = zeros(1, 0);
            if regularize>0
                objRegularize = regularize*z;
            end
            obj = [objRegress, objRegularize];
        end%
    %)
end%


function [gamma, exitFlag] = local_estimateResidualModel(y, X, fixed, rm, inxObjectiveRange, optimOptions)
    %(
    persistent DEFAULT_OPTIM_OPTIONS
    if isempty(DEFAULT_OPTIM_OPTIONS)
        DEFAULT_OPTIM_OPTIONS = optimoptions("lsqnonlin", "display", "none");
    end
    if isempty(optimOptions)
        optimOptions = DEFAULT_OPTIM_OPTIONS;
    end

    numObservations = size(y, 2);
    inxFixed = ~isnan(fixed);

    %
    % Adjust for within-sample missing observations
    %
    inxMissing = any(~isfinite([y; X]), 1);
    y(:, inxMissing) = 0;
    X(:, inxMissing) = 0;

    if any(inxFixed)
        y = y - fixed(inxFixed)*X(inxFixed, :);
        X = X(~inxFixed, :);
    end
    yt = transpose(y);
    Xt = transpose(X);
    [gamma, ~, ~, exitFlag] = lsqnonlin( ...
        @here_objectiveFunc ...
        , zeros(1, rm.NumParameters) ...
        , -ones(1, rm.NumParameters) ...
        , ones(1, rm.NumParameters) ...
        , optimOptions ...
    );
    
    return
        function obj = here_objectiveFunc(p)
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
            obj(~inxObjectiveRange) = 0;
        end%
    %)
end%


function [lhs, rhs, subBlock, inxBaseRange] = local_blackout(lhs, rhs, subBlock, maxLag, inxBaseRange, extdRange, before, after, journal)
    %(
    if isinf(before) && isinf(after)
        return
    end
    if ~isinf(before)
        pos = round(before - extdRange(1) + 1);
        if pos>1
            lhs(:, 1:pos-1) = NaN;
            rhs(:, 1:pos-1) = NaN;
            subBlock(:, 1:pos+maxLag-1) = NaN;
            inxBaseRange(:, 1:pos-1) = false;
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
            subBlock(:, pos+1:end) = NaN;
            inxBaseRange(:, pos+1:end) = false;
            if journal.IsActive
                write(journal, "Blackout after " + dater.toDefaultString(extdRange(pos)));
            end
        end
    end
    %)
end%


function local_reportFailedEstimation(exitFlags, this, context, whenEstimationFailed)
    %(
    if lower(whenEstimationFailed)=="error"
        func = @exception.error;
    else
        func = @exception.warning;
    end
    lhsNames = collectLhsNames(this);
    [q, v] = find(~isnan(exitFlags) & exitFlags<=0);
    qv = sortrows([q, v], 1);
    temp = reshape([reshape(string(qv(:,2)), 1, []); reshape(lhsNames(qv(:,1)), 1, [])], [], 1);
    func([
        "Explanatory:ResidualModelFailed"
        context + " estimation for this LHS variable failed to converge [Page|Variant:%s]: %s "
    ], temp);
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

