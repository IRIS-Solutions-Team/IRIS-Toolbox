% Type `web Model/simulate.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function [outputDb, outputInfo, frameDb] = simulate(this, inputDb, baseRange, options)

arguments
    this Model {validate.mustBeA(this, "Model")}
    inputDb (1, 1) {locallyValidateInputDb}
    baseRange (1, :) {locallyValidateBaseRange}

    options.Anticipate {locallyValidateAnticipateOption} = []
    options.Deviation (1, 1) logical = false
    options.EvalTrends = @auto
    options.Contributions (1, 1) logical = false
    options.IgnoreShocks (1, 1) logical = false
    options.MaxFrames (1, 1) double {mustBeInteger, mustBeNonnegative} = intmax()
    options.Plan {locallyValidatePlanOption} = []
    options.Progress (1, 1) logical = false
    options.Solver {locallyValidateSolverOption} = @auto
    options.SparseShocks (1, 1) logical = false
    options.SystemProperty {locallyValidateSystemPropertyOption} = false

    options.SuccessOnly (1, 1) logical = false
    options.Blocks (1, 1) logical = false
    options.Log {locallyValidateLogOption} = []
    options.Unlog {locallyValidateLogOption} = []

    options.Method {locallyValidateMethodOption} = solver.Method.FIRSTORDER
    options.Window {locallyValidateWindowOption} = @auto
    options.Terminal (1, 1) string {mustBeMember(options.Terminal, ["firstOrder", "FirstOrder", "data", "Data"])} = "firstOrder"
    options.StartIterationsFrom (1, 1) string {mustBeMember(options.StartIterationsFrom, ["firstOrder", "FirstOrder", "data", "Data"])} = "firstOrder"
    options.PrepareGradient (1, 1) logical = true

    options.OutputData (1, 1) string {mustBeMember(options.OutputData, ["databank", "simulate.Data"])} = "databank"
    options.OutputType (1, 1) {validate.mustBeOutputType} = @auto
    options.PrependInput (1, 1) logical = false
    options.AppendInput (1, 1) logical = false
    options.AddParameters (1, 1) logical = true
    options.AddToDatabank = false

    % Legacy options
    options.Initial = []
    options.AppendPresample = []
    options.AppendPostsample = []
end

legacy = [
    "Initial", "StartIterationsFrom"
    "AppendPresample", "PrependInput"
    "AppendPostsample", "AppendInput"
];

for i = 1 : size(legacy, 2)
    if ~isempty(options.(legacy(i, 1)))
        options.(legacy(i, 2)) = string(options.(legacy(i, 1)));
        exception.warning([
            "Legacy:Option"
            "Option %s= is obsolete and will be removed from IrisT in the future. "
            "Use %s= instead. "
        ], legacy(i, :));
    end
end
%)
% >=R2019b


% <=R2019a
%{
function [outputDb, outputInfo, frameDb] = simulate(this, inputDb, baseRange, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addParameter(pp, "Anticipate", []);
    addParameter(pp, "Deviation", false);
    addParameter(pp, "EvalTrends", @auto);
    addParameter(pp, "Contributions", false);
    addParameter(pp, "IgnoreShocks", false);
    addParameter(pp, "MaxFrames", intmax());
    addParameter(pp, "Plan", []);
    addParameter(pp, "Progress", false);
    addParameter(pp, "Solver", @auto);
    addParameter(pp, "SparseShocks", false);
    addParameter(pp, "SystemProperty", false);

    addParameter(pp, "SuccessOnly", false);
    addParameter(pp, "Blocks", false);
    addParameter(pp, "Log", []);
    addParameter(pp, "Unlog", []);

    addParameter(pp, "Method", solver.Method.FIRSTORDER);
    addParameter(pp, "Window", @auto);
    addParameter(pp, "Terminal", "firstOrder");
    addParameter(pp, {"StartIterationsFrom", "Initial"}, "firstOrder");
    addParameter(pp, "PrepareGradient", true);

    addParameter(pp, "OutputData", "databank");
    addParameter(pp, "OutputType", @auto);
    addParameter(pp, {"PrependInput", "AppendPresample"}, false);
    addParameter(pp, {"AppendInput", "AppendPostsample"}, false);
    addParameter(pp, "AddParameters", true);
    addParameter(pp, "AddToDatabank", false);
end
options = parse(pp, varargin{:});
%}
% <=R2019a


if isequal(options.EvalTrends, @auto)
    options.EvalTrends = ~options.Deviation;
end

if ~isequal(baseRange, @auto)
    baseRange = double(baseRange);
end

options.Method = solver.Method(options.Method);
if options.Method==solver.Method.SELECTIVE && ~any(this.Equation.InxHashEquations)
    options.Method = solver.Method.FIRSTORDER;
    exception.warning([
        "Model:FirstOrderInsteadSelective"
        "The model has no hash equations; switching from Method=Selective "
        "to Method=FirstOrder. "
    ]);
end


[options.Window, baseRange, options.Plan] = resolveWindowAndBaseRange(options.Window, options.Method, baseRange, options.Plan);
plan = locallyResolvePlan(this, baseRange, options.Plan, options.Anticipate);
isAsynchronous = isequal(inputDb, "asynchronous");
numVariants = countVariants(this);
options.Solver = locallyParseSolverOption(options.Solver, options.Method);
options.Terminal = locallyResolveTerminal(options.Terminal, options.Method);


% Maintain a clean copy of input data if there are more than sequential
% simulation plans
needsCleanCopy = false;


% All simulation methods except PERIOD require a solved Model
locallyCheckSolvedModel(this, options.Method, options.StartIterationsFrom, options.Terminal);


% Prepare running data
runningData = simulate.InputOutputData();
runningData.InxE = getIndexByType(this.Quantity, 31, 32);
runningData.IsAsynchronous = isAsynchronous;
runningData.PrepareOutputInfo = nargout>=2;
runningData.PrepareFrameData = nargout>=3;


% Retrieve data from intput databank, set up ranges
hereExtractInputData();

% Check Contributions= only after preparing data and resolving the number
% of runs (variants, pages)
hereResolveContributionsConflicts();

hereCopyOptionsToRunningData();

if options.Contributions
    % Expand and set up YXEPG to prepare contributions simulation
    herePrepareContributions();
end


% Check initial conditions for NaNs
hereCheckInitialConditions();


% Set up Blazer objects
hereSetupDefaultBlazers();


% Define time frames and check for deficiency of simulation plans; can be
% done only after we expand the data for contributions
defineFrames(runningData, options);


systemProperty = hereSetupSystemProperty();
if ~isequal(options.SystemProperty, false)
    outputDb = systemProperty;
    return
end

progress = [ ];
if options.Progress
    progress = ProgressBar('[IrisToolbox] @Model/simulate Progress');
end


%===========================================================================
numRuns = runningData.NumPages;
for i = 1 : numRuns
    simulateFrames(this, systemProperty, i);
    if options.Progress
        update(progress, i/numRuns);
    end
end
%===========================================================================


if options.Contributions
    herePostprocessContributions();
end

if isAsynchronous
    return
end

outputDb = hereCreateOutputData();

if runningData.PrepareOutputInfo
    outputInfo = hereCreateOutputInfo();
end

if runningData.PrepareFrameData
    frameDb = hereCreateFrameDb();
end

return

    function hereResolveContributionsConflicts()
        %(
        if options.Contributions && plan.NumOfExogenizedPoints>0
            exception.error([
                "Model:CannotEvalContributionsWithExogenized"
                "Option Contributions=true cannot be used in simulations with exogenized variables." 
            ]);
        end
        if options.Contributions && runningData.NumPages>1
            exception.error([
                "Model:CannotEvalContributionsWithMultipleDataSets"
                "Option Contributions=true cannot be used in simulations "
                "with multiple parameter variants or data pages."
            ]);
        end
        %)
    end%


    function hereCopyOptionsToRunningData()
        %(
        numRuns = runningData.NumPages;
        runningData.Plan = plan;
        runningData.Window = options.Window;
        runningData.SuccessOnly = options.SuccessOnly;
        runningData.SparseShocks = options.SparseShocks;
        runningData.Method = repmat(options.Method, 1, numRuns);
        runningData.Deviation = repmat(options.Deviation, 1, numRuns);
        runningData.NeedsEvalTrends = repmat(options.EvalTrends, 1, numRuns);
        runningData.SolverOptions = options.Solver;
        %)
    end%


    function hereExtractInputData()
        %(
        numDummyPeriods = hereCalculateNumDummyPeriods();
        baseRangePlusDummy = [baseRange(1), baseRange(end) + numDummyPeriods];

        % Check the input databank; treat all names as optional, and check for
        % missing initial conditions later
        requiredNames = string.empty(1, 0);
        optionalNames = this.Quantity.Name(this.Quantity.Type~=4);
        allowedNumeric = string.empty(1, 0);
        allowedLog = string.empty(1, 0);
        context = "";
        dbInfo = checkInputDatabank( ...
            this, inputDb, baseRange ...
            , requiredNames, optionalNames ...
            , allowedNumeric, allowedLog ...
            , context ...
        );

        % Retrieve data from the input databank
        [runningData.YXEPG, ~, extdRange, ~, runningData.MaxShift, runningData.TimeTrend] ...
            = data4lhsmrhs( ...
                this, inputDb, baseRangePlusDummy ...
                , "dbInfo", dbInfo ...
                , "resetShocks", true ...
                , "ignoreShocks", options.IgnoreShocks ...
                , "numDummyPeriods", numDummyPeriods ...
            );

        if needsCleanCopy
            runningData.CleanYXEPG = runningData.YXEPG;
        end

        extdStart = extdRange(1);
        extdEnd = extdRange(end);
        runningData.ExtendedRange = [extdStart, extdEnd];
        runningData.BaseRangeColumns = colon( ...
            round(baseRange(1) - extdStart + 1) ...
            , round(baseRange(end) - extdStart + 1) ...
        );
        numPages = runningData.NumPages;
        if numPages==1 && numVariants>1
            % Expand number of data sets to match number of parameter variants
            runningData.YXEPG = repmat(runningData.YXEPG, 1, 1, numVariants);
        end
        numRuns = runningData.NumPages;
        runningData.InxOfInitInPresample = getInxOfInitInPresample(this, runningData.BaseRangeColumns(1));
        runningData.Method = repmat(options.Method, 1, numRuns);
        runningData.Deviation = repmat(options.Deviation, 1, numRuns);
        runningData.NeedsEvalTrends = repmat(options.EvalTrends, 1, numRuns);
        %)
    end%


    function herePrepareContributions()
        %(
        firstColumnToSimulate = runningData.BaseRangeColumns(1);
        inxLog = this.Quantity.InxLog;
        inxE = getIndexByType(this, 31, 32);
        posE = find(inxE);
        numE = nnz(inxE);
        numRuns = numE + 2;
        runningData.YXEPG = repmat(runningData.YXEPG, 1, 1, numRuns);
        % Zero out initial conditions in shock contributions
        runningData.YXEPG(inxLog, 1:firstColumnToSimulate-1, 1:numE) = 1;
        runningData.YXEPG(~inxLog, 1:firstColumnToSimulate-1, 1:numE) = 0;
        for ii = 1 : numE
            temp = runningData.YXEPG(posE(ii), :, ii);
            runningData.YXEPG(inxE, :, ii) = 0;
            runningData.YXEPG(posE(ii), :, ii) = temp;
        end
        % Zero out all shocks in init+const contributions
        runningData.YXEPG(inxE, firstColumnToSimulate:end, end-1) = 0;

        if options.Method==solver.Method.FIRSTORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            runningData.YXEPG(inxLog, :, end) = 1;
            runningData.YXEPG(~inxLog, :, end) = 0;
        end

        runningData.Method = repmat(solver.Method.FIRSTORDER, 1, numRuns);
        if options.Method==solver.Method.FIRSTORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            runningData.Method(end) = solver.Method.NONE;
        else
            runningData.Method(end) = options.Method;
        end
        runningData.Deviation = true(1, numRuns);
        runningData.Deviation(end-1:end) = options.Deviation;
        runningData.NeedsEvalTrends = false(1, numRuns);
        runningData.NeedsEvalTrends(end-1:end) = options.EvalTrends;
        %)
    end%


    function hereSetupDefaultBlazers()
        %(
        switch options.Method
            case solver.Method.STACKED
                defaultBlazer = solver.blazer.Stacked.forModel(this, options);
                run(defaultBlazer);
                if options.Blocks
                    exogenizedBlazer = solver.blazer.Stacked.forModel(this, options);
                else
                    exogenizedBlazer = [ ];
                end
            case solver.Method.PERIOD
                defaultBlazer = solver.blazer.Period.forModel(this, options);
                run(defaultBlazer);
                if options.Blocks
                    exogenizedBlazer = solver.blazer.Period.forModel(this, options);
                else
                    exogenizedBlazer = [ ];
                end
            case solver.Method.SELECTIVE
                defaultBlazer = solver.blazer.Selective();
                exogenizedBlazer = defaultBlazer;
            otherwise
                defaultBlazer = solver.blazer.FirstOrder();
                exogenizedBlazer = [ ];
        end
        runningData.DefaultBlazer = defaultBlazer;
        runningData.ExogenizedBlazer = exogenizedBlazer;
        %)
    end%


    function systemProperty = hereSetupSystemProperty()
        %(
        systemProperty = SystemProperty(this);
        systemProperty.Function = @simulateFrames;
        systemProperty.MaxNumOfOutputs = 1;
        systemProperty.NamedReferences = cell(1, 1);
        systemProperty.NamedReferences{1} = this.Quantity.Name;
        systemProperty.CallerData = runningData;
        if isequal(options.SystemProperty, false)
            systemProperty.OutputNames = cell(1, 0);
        else
            systemProperty.OutputNames = options.SystemProperty;
        end
        %)
    end%


    function hereCheckInitialConditions()
        %(
        if isAsynchronous
            return
        end
        % Report missing initial conditions
        firstColumnSimulation = runningData.BaseRangeColumns(1);
        inxNaNPresample = any(isnan(runningData.YXEPG(:, 1:firstColumnSimulation-1, :)), 3);
        checkInitialConditions(this, inxNaNPresample, firstColumnSimulation);
        %)
    end%


    function numDummyPeriods = hereCalculateNumDummyPeriods()
        %(
        numDummyPeriods = options.Window - 1;
        if ~strcmpi(options.Method, 'FirstOrder')
            [~, maxShift] = getActualMinMaxShifts(this);
            numDummyPeriods = numDummyPeriods + maxShift;
        end
        if numDummyPeriods>0
            plan = extendWithDummies(plan, numDummyPeriods);
        end
        %)
    end%


    function outputDb = hereCreateOutputData()
        %(
        if startsWith(options.OutputData, "databank", "ignoreCase", true)
            columns = 1 : runningData.BaseRangeColumns(end);
            startDate = runningData.ExtendedRange(1);
            outputDb = locallyCreateOutputDb(this, runningData.YXEPG(:, columns, :), startDate, options);
            if validate.databank(inputDb)
                outputDb = appendData(this, inputDb, outputDb, baseRange, options);
            end
        else
            outputDb = runningData.YXEPG;
        end
        %)
    end%


    function outputInfo = hereCreateOutputInfo()
        %(
        outputInfo = struct();
        outputInfo.BaseRange = DateWrapper(runningData.BaseRange);
        outputInfo.ExtendedRange = DateWrapper(runningData.ExtendedRange);
        outputInfo.StartIterationsFrom = options.StartIterationsFrom;
        outputInfo.Terminal = options.Terminal;
        outputInfo.FrameColumns = runningData.FrameColumns;
        outputInfo.FrameDates = runningData.FrameDates;
        outputInfo.Success =  runningData.Success;
        outputInfo.ExitFlags = runningData.ExitFlags;
        outputInfo.DiscrepancyTables = runningData.DiscrepancyTables;
        outputInfo.ProgressBar = progress;
        %)
    end%


    function frameDb = hereCreateFrameDb()
        %(
        frameDb = cell(1, numRuns);
        for i = 1 : numRuns
            numFrames = size(runningData.FrameColumns{i}, 1);
            startDate = runningData.ExtendedRange(1);
            frameDb{i} = locallyCreateOutputDb(this, runningData.FrameData{i}.YXEPG, startDate, options);
        end
        %)
    end%


    function herePostprocessContributions()
        %(
        inxLog = this.Quantity.InxLog;
        if runningData.Method(end)~=solver.Method.NONE
            % Calculate contributions of nonlinearities
            runningData.YXEPG(inxLog, :, end) =  runningData.YXEPG(inxLog, :, end) ...
                                    ./ prod(runningData.YXEPG(inxLog, :, 1:end-1), 3);
            runningData.YXEPG(~inxLog, :, end) = runningData.YXEPG(~inxLog, :, end) ...
                                     - sum(runningData.YXEPG(~inxLog, :, 1:end-1), 3);
        end
        %)
    end%
end%

%
% Local Functions
%

function flag = locallyValidateSolverOption(x)
    %(
    flag = isequal(x, @auto) || isa(x, 'solver.Options') || locallyValidateSolverName(x) ...
           || (iscell(x) && locallyValidateSolverName(x{1}) && validate.nestedOptions(x(2:2:end)));
    if flag
        return
    end
    error("Input value must be valid solver settings.");
    %)
end%


function flag = locallyValidateSolverName(x)
    %(
    if ~ischar(x) && ~isstring(x) && ~isa(x, 'function_handle')
        flag = false;
        return
    end
    if isa(x, 'function_handle')
        x = char(x);
    end
    x = string(x);
    listSolverNames = [ 
        "auto" 
        "iris-qad"
        "iris-quickNewton"
        "iris-newton"
        "iris-qnsd"
        "qad"
        "quickNewton"
        "newton"
        "qnsd"
        "iris"
        "fminsearch"
        "lsqnonlin"
        "fsolve"      
    ];
    flag = any(strcmpi(x, listSolverNames));
    %)
end%


function [windowOption, baseRange, plan] = resolveWindowAndBaseRange(windowOption, methodOption, baseRange, plan)
    %(
    if isequal(baseRange, @auto)
        if isequal(windowOption, @auto) 
            baseRange = 1;
            windowOption = 1;
            return
        else
            baseRange = 1 : round(windowOption);
            return
        end
    end

    lenBaseRange = round(baseRange(end) - baseRange(1) + 1);
    if isequal(windowOption, @auto)
        if methodOption==solver.Method.FIRSTORDER
            windowOption = 1;
        else
            windowOption = lenBaseRange;
        end
    end
    if windowOption>lenBaseRange
        baseRange = dater.colon(baseRange(1), dater.plus(baseRange(1), windowOption-1));
        if isa(plan, 'Plan')
            plan.End = baseRange(end);
        end
    end
    %)
end%


function solverOption = locallyParseSolverOption(solverOption, methodOption)
    %(
    if isa(solverOption, 'solver.Options') || isa(solverOption, 'optim.options.SolverOptions')
        return
    end

    switch methodOption
        case solver.Method.FIRSTORDER
            solverOption = [ ];
        case solver.Method.SELECTIVE
            defaultSolver = 'Iris-QaD';
            silent = false;
            solverOption = solver.Options.parseOptions(solverOption, defaultSolver, silent);
        case {solver.Method.STACKED, solver.Method.PERIOD}
            defaultSolver = 'Iris-Newton';
            silent = false;
            solverOption = solver.Options.parseOptions(solverOption, defaultSolver, silent);
    end
    %)
end%


function locallyCheckSolvedModel(this, method, initial, terminal)
    %(
    if ~needsFirstOrderSolution(method, this, initial, terminal) ...
        || all(beenSolved(this))
        return
    end
    exception.error([
        "Model:NeedsFirstOrderSolution"
        "Model simulation needs a valid first-order solution to be "
        "available given the options Method, Initial and Terminal. "
    ]);
    %)
end%


function outputDb = locallyCreateOutputDb(this, YXEPG, startDate, options)
    %(
    if options.Contributions
        comments = getLabelsForShockContributions(this.Quantity);
    else
        comments = getLabelsOrNames(this.Quantity);
    end

    inxInclude = ~getIndexByType(this.Quantity, 4);
    timeSeriesConstructor = @default;
    outputDb = databank.backend.fromDoubleArrayNoFrills( ...
        YXEPG ...
        , this.Quantity.Name ...
        , startDate ...
        , comments ...
        , inxInclude ...
        , timeSeriesConstructor ...
        , options.OutputType ...
        , options.AddToDatabank ...
    );
    if options.AddParameters
        outputDb = addToDatabank("default", this, outputDb);
    end
    %)
end%


function terminal = locallyResolveTerminal(terminal, method)
    %(
    if method==solver.Method.STACKED 
        return
    elseif method==solver.Method.PERIOD
        terminal = "data";
    else
        terminal = "none";
    end
    %)
end%


function plan = locallyResolvePlan(this, baseRange, plan, anticipate)
    %(
    if isa(plan, 'Plan')
        if ~isempty(anticipate)
            hereThrowError();
        end
        checkPlanConsistency(this, baseRange, plan);
        return
    end
    if islogical(plan)
        if ~isempty(anticipate)
            hereThrowError();
        end
        plan = Plan(this, baseRange, "anticipate", plan);
        return
    end
    if ~isempty(anticipate)
        plan = Plan(this, baseRange, "anticipate", anticipate);
        return
    end
    plan = Plan(this, baseRange, "anticipate", true);
    return
        function hereThrowError()
            exception.error([
                "Model:OptionsPlanAnticipate"
                "Options Plan= and Anticipate= cannot be used at the same time."
            ]);
        end%
    %)
end%


function locallyValidateAnticipateOption(x)
    %(
    if isempty(x) || isequal(x, true) || isequal(x, false)
        return
    end
    error("Input argument must be true or false.");
    %)
end%


function locallyValidatePlanOption(x)
    %(
    if isempty(x) || isequal(x, true) || isequal(x, false) || isa(x, 'Plan')
        return
    end
    error("Input argument must be true or false.");
    %)
end%


function locallyValidateSystemPropertyOption(x)
    %(
    if isequal(x, false) || validate.list(x)
        return
    end
    error("Input argument must be false or a list of names.");
    %)
end%


function locallyValidateLogOption(x)
    %(
    if isempty(x) || isequal(x, @all) || validate.list(x)
        return
    end
    error("Input argument must be empty, @all or a list of names.");
    %)
end%


function locallyValidateMethodOption(x)
    %(
    try
        solver.Method(string(x));
    catch
        error("Input argument must be a valid solver.Method.");
    end
    %)
end%


function locallyValidateWindowOption(x)
    %(
    if isequal(x, @auto) || validate.roundScalar(x, 1, Inf)
        return
    end
    error("Input argument must be @auto or a positive integer.");
    %)
end%


function locallyValidateInputDb(x)
    if validate.databank(x)
        return
    end
    if isequal(x, "asynchronous")
        return
    end
    error("Input value must be a databank.")
end%


function locallyValidateBaseRange(x)
    if isequal(x, @auto)
        return
    end
    if validate.properRange(x)
        return
    end
    error("Input value must be a date range.");
end%
