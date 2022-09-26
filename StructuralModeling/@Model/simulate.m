%{
% 
% # `simulate` ^^(Model)^^
% 
% {== Run a model simulation ==}
% 
% 
% ## Syntax 
% 
%     [outputDb, outputInfo, frameDb] = simulate(model, inputDb, range, ___)
% 
% 
% ## Input arguments 
% 
% __`model`__ [ Model ]
% > 
% > Model object with a valid solution avalaible for each of its parameter
% > variants.
% > 
% 
% __`inputDb`__ [ struct | Dictionary ]
% > 
% > Input databank from which the following data will be retrieved:
% >  
% > * initial conditions for the lags of transition variables; use
% >   `access(model, "initials")` to get the list of the necessary initial
% >   conditions;
% >  
% > * shocks within the simulation range; if shocks are missing, the default
% >   zero value is used in the simulation;
% >  
% > * data points for the transition variables exogenized in the simulation
% >   `Plan` (entered optionally through the `plan=` option);
% >  
% > * initial paths for transition variables in nonlinear simulations
% >   (`method="stacked"` or `method="period"`) when the initial iteration is
% >   requested to be taken from the input data and not the default
% >   first-order simulation, `startIterationsFrom="data"`.
% > 
% 
% __`range`__ [ DateWrapper | numeric ]
% > 
% > Simulation range; the simulation range is always from the first date to
% > the last date specified in the `range`.
% > 
% 
% 
% ## Output arguments 
% 
% __`outputDb`__ [ struct | Dictionary ]
% > 
% > Databank (struct or Dictionary) with the simulation results; if options
% > `prependInput=` or `appendInput=` are not used, the time series in
% > `outputDb` span the simulation `range` plus all necessary initial
% > conditions for those variables that have lags in the model.
% > 
% 
% __`outputInfo`__ [ struct ]
% > 
% > Info struct with details on the simulation; the `outputInfo` struct
% > contains the following fields:
% >  
% > * `.FrameColumns`
% > * `.FrameDates` 
% > * `.BaseRange` 
% > * `.ExtendedRange` 
% > * `.Success` 
% > * `.ExitFlags` 
% > * `.DiscrepancyTables` 
% > * `.ProgressBar` 
% > 
% 
% __`frameDb`__ [ cell ]
% > 
% > Only returned nonempty when `method="stacked"`: Nested cell arrays with
% > databanks containing the simulation results of each individual frame; the
% > `frameDb{i}{j}` element is the output databank from simulating the j-th
% > frame in the i-th variant or data page.
% > 
% 
% 
% ## General options 
% 
% __`anticipate=true`__ [ `true` | `false` ]
% > 
% > Default anticipation status for shocks placed at future times; the
% > anticipation status can be modified individually for each shock by using
% > real/imaginary values in the `inputDb`, or by specifying anticipation
% > status in the simulation plan in the `plan=` option.
% > 
% 
% 
% __`appendInput=false`__ [ `true` | `false` ]
% > 
% > If `true`, the data from `inputDb` succeeding the simulation range
% > will be included in the output time series returned in `outputDb`.
% > 
% 
% 
% __`contributions=false`__ [ `true` | `false`]
% > 
% > Break the simulation down into the contributions of individual types of
% > shocks.
% > 
% 
% __`ignoreShocks=false`__ [ `true` | `false` ]
% > 
% > Reset all shocks in the input databank to zero. 
% > 
% 
% 
% __`method="firstOrder"`__ [ "firstOrder" | "stacked" | "period" ]
% > 
% > Simulation method:
% >  
% > * `method="firstOrder"` - use a first-order approximate solution;
% >  
% > * `method="stacked"` - solve the model numerically as a
% >   stacked-time system of nonlinear-equations using a quasi-Newton method.
% >  
% > * `method="period"` - solve the model numerically as a system of
% >   nonlinear-equations period by period using a quasi-Newton method; in
% >   forward-looking models, the model-consistent expectations are replaced
% >   with the values found in the `inputDb`
% >  
% > The nonlinear simulation methods also further use the `solver=` option to
% > specify the settings for the nonlinear solver.
% > 
% 
% 
% __`plan=[]`__ [ empty | Plan ]
% > 
% > Specify a [simulation plan](../@Plan/index.md) with anticipation, inversion and conditioning
% > information.
% > 
% 
% __`deviation=false`__ [ `true` | `false` ]
% > 
% > If true, both the input data and the output data are (and are expected
% > to be) in the form of deviations from steady state:
% > 
% > * for variables not declared as `log-variables`, the deviations from
% > steady state are calculated as a plain difference: $x_t - \bar x_t$
% > 
% > * for variables declared as `log-variables`, the deviations from
% > steady state are calculated as a ratio: $x_t / \bar x_t$.
% > 
% 
% __`includeLog=false`__ [ `true` | `false` ]
% > 
% > Include the paths for the logarithm of those variables that are declared
% > as `!log-variables` in the model; these will be reported under the names
% > prepended with the prefix `log_`.
% > 
% 
% 
% __`prependInput=false`__ [ `true` | `false` ]
% > 
% > If `true`, the data from `inputDb` preceding the simulation range
% > will be included in the output time series returned in `outputDb`.
% > 
% 
% 
% 
% ## Options for nonlinear simulation methods
% 
% The following options take effect when `method="stacked"` or
% `method="period"`.
% 
% 
% __`blocks=false`__ [ `true` | `false` ]
% > 
% > In simulations with no model inversion or conditioning: Apply
% > sequential block decomposition of the dynamic equations, and calculate
% > the simulation block by block.
% > 
% 
% 
% __`solver=@auto`__ [ `@auto` | string | cell ] 
% >  
% > The name of the numerical solver to use for solving nonlinear simulations
% > (`method="stacked"` or `method="period"`), optionally also with solver
% > settings; see Description.
% > 
% 
% 
% __`successOnly=false`__ [ `true` | `false` ]
% > 
% > Stop the simulation when a variant/block fails to converge, and do not
% > proceed. If `successOnly=false`, the simulation proceeds to the next
% > variant/block, and the failure is reported in `outputInfo`.
% > 
% 
% __`startIterationsFrom="firstOrder"`__ [ `"firstOrder"` | `"data"` ]
% > 
% > Method to determine the starting paths for variables:
% > 
% > * `"firstOrder"` - use first order solution to simulate the entire paths;
% > 
% > * `"data"` - use the paths from the `inputDb`.
% > 
% 
% __`terminal="firstOrder"`__ [ `"firstOrder"` | `"data"` ]
% > 
% > Method to determine terminal condition in nonlinear simulations of
% > forward-looking models:
% > 
% > * `"firstOrder"` - use the first order solution to simulate terminal
% >   condition beyond the last nonlinear point;
% > 
% > * `"data"` - use fixed terminal condition supplied in the `inputDb`.
% > 
% 
% 
% ## Description 
% 
% In its plain vanilla form, this function calculates a first-order
% simulation the `model` on the simulation `range` (from the first date in
% `range` until the last date in `range`), extracting two pieces of
% information from the `inputDb`:
% 
% * initial condition, i.e. values for the lags of model variables before the
%   start date,
% 
% * shocks on the simulation range.
% 
% 
% ### Numerical solver settings in nonlinear simulations
% 
% When `method="stacked"` or `method="period"`, the model is solved as a
% nonlinear system of equations using an IrisT quasi-Newton solver. There are two
% basic varieties of the numerical solver in IrisT:
% 
% * a quasi-Newton, called `"iris-newton"`; this is a traditional Newton
%   algorithm with optional step size optimization;
% 
% * a quasi-Newton-steepest-descent, called `"iris-qnsd"`; this solver
%   combines the quasi-Newton step with a Cauchy (steepest descent) step and
%   regularizes the Jacobian matrix in the process.
% 
% For most simulations, the `"iris-newton"` (which is the default choice) is
% the appropriate choice; however, you can still modify some of the settings
% by specifying a cell array whose first element is the name of the solver
% (`"newton"` or `"qnsd"`) followed by any number of name-value
% pairs for the individual settings; for instance:
% 
% ```matlab
% outputDb = simulate( ...
%     model, inputDb, range ...
%     , method="stacked" ...
%     , solver={"iris-newton", "maxIterations", 100, "functionTolerance", 1e-5} ...
% );
% ```
% 
% See [Numerical solver settings](../Solver/index.md) for the description of all settings.
% 
% 
% ## Example 
% 
% 
% 
%}
% --8<--


% >=R2019b
%{
function [outputDb, outputInfo, frameDb] = simulate(this, inputDb, baseRange, opt)

arguments
    this Model {validate.mustBeA(this, "Model")}
    inputDb (1, 1) {local_validateInputDb}
    baseRange (1, :) {local_validateBaseRange}

    opt.Anticipate {local_validateAnticipateOption} = []
    opt.Deviation (1, 1) logical = false
    opt.Contributions (1, 1) logical = false
    opt.IgnoreShocks (1, 1) logical = false
    opt.MaxFrames (1, 1) double {mustBeInteger, mustBeNonnegative} = intmax()
    opt.Plan {local_validatePlanOption} = []
    opt.Progress (1, 1) logical = false
    opt.Solver {local_validateSolverOption} = @auto
    opt.SparseShocks (1, 1) logical = false
    opt.SystemProperty {local_validateSystemPropertyOption} = false

    opt.SuccessOnly (1, 1) logical = false
    opt.Blocks (1, 1) logical = false
    opt.Log {local_validateLogOption} = []
    opt.Unlog {local_validateLogOption} = []

    opt.Method {local_validateMethodOption} = solver.Method.FIRSTORDER
    opt.Window {local_validateWindowOption} = @auto
    opt.Terminal (1, 1) string {mustBeMember(opt.Terminal, ["firstOrder", "FirstOrder", "data", "Data"])} = "firstOrder"
    opt.StartIterationsFrom (1, 1) string {mustBeMember(opt.StartIterationsFrom, ["firstOrder", "FirstOrder", "data", "Data"])} = "firstOrder"
        opt.Initial__StartIterationsFrom = [];
    opt.PrepareGradient (1, 1) logical = true
    opt.OutputData (1, 1) string {mustBeMember(opt.OutputData, ["databank", "simulate.Data"])} = "databank"
    opt.OutputType (1, 1) {validate.mustBeOutputType} = @auto
    opt.PrependInput (1, 1) logical = false
        opt.AppendPresample__PrependInput = []
    opt.AppendInput (1, 1) logical = false
        opt.AppendPostsample__AppendInput = []
    opt.AddParameters (1, 1) logical = true
    opt.AddToDatabank = false
    opt.IncludeLog (1, 1) logical = false
end
%}
% >=R2019b


% <=R2019a
%(
function [outputDb, outputInfo, frameDb] = simulate(this, inputDb, baseRange, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Anticipate", []);
    addParameter(ip, "Deviation", false);
    addParameter(ip, "Contributions", false);
    addParameter(ip, "IgnoreShocks", false);
    addParameter(ip, "MaxFrames", intmax());
    addParameter(ip, "Plan", []);
    addParameter(ip, "Progress", false);
    addParameter(ip, "Solver", @auto);
    addParameter(ip, "SparseShocks", false);
    addParameter(ip, "SystemProperty", false);

    addParameter(ip, "SuccessOnly", false);
    addParameter(ip, "Blocks", false);
    addParameter(ip, "Log", []);
    addParameter(ip, "Unlog", []);

    addParameter(ip, "Method", solver.Method.FIRSTORDER);
    addParameter(ip, "Window", @auto);
    addParameter(ip, "Terminal", "firstOrder");
    addParameter(ip, "StartIterationsFrom", "firstOrder");
        addParameter(ip, "Initial__StartIterationsFrom", []);
    addParameter(ip, "PrepareGradient", true);

    addParameter(ip, "OutputData", "databank");
    addParameter(ip, "OutputType", @auto);
    addParameter(ip, "PrependInput", false);
        addParameter(ip, "AppendPresample__PrependInput", []);
    addParameter(ip, "AppendInput", false);
        addParameter(ip, "AppendPostsample__AppendInput", []);
    addParameter(ip, "AddParameters", true);
    addParameter(ip, "AddToDatabank", false);
    addParameter(ip, "IncludeLog", false);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], true);


if ~isequal(baseRange, @auto)
    baseRange = double(baseRange);
end

opt.Method = solver.Method(opt.Method);
if opt.Method==solver.Method.SELECTIVE && ~any(this.Equation.InxHashEquations)
    opt.Method = solver.Method.FIRSTORDER;
    exception.warning([
        "Model:FirstOrderInsteadSelective"
        "The model has no hash equations; switching from Method=Selective "
        "to Method=FirstOrder. "
    ]);
end


[opt.Window, baseRange, opt.Plan] = resolveWindowAndBaseRange(opt.Window, opt.Method, baseRange, opt.Plan);
plan = local_resolvePlan(this, baseRange, opt.Plan, opt.Anticipate);
isAsynchronous = all(strcmpi(inputDb, 'asynchronous'));
numVariants = countVariants(this);
opt.Solver = local_parseSolverOption(opt.Solver, opt.Method);
opt.Terminal = local_resolveTerminal(opt.Terminal, opt.Method);


% Maintain a clean copy of input data if there are more than sequential
% simulation plans
needsCleanCopy = false;


% All simulation methods except PERIOD require a solved Model
local_checkSolvedModel(this, opt.Method, opt.StartIterationsFrom, opt.Terminal);


% Prepare running data
runningData = simulate.InputOutputData();
runningData.InxE = getIndexByType(this.Quantity, 31, 32);
runningData.IsAsynchronous = isAsynchronous;
runningData.PrepareOutputInfo = nargout>=2;
runningData.PrepareFrameData = nargout>=3;

% Retrieve data from intput databank, set up ranges, evaluate measurement
% trends if needed
runningData = here_extractInputData(runningData);

% Check Contributions= only after preparing data and resolving the number
% of runs (variants, pages)
here_resolveContributionsConflicts();

here_copyOptionsToRunningData();

if opt.Contributions
    % Expand and set up YXEPG to prepare contributions simulation
    here_prepareContributions();
end


% Check initial conditions for NaNs
here_checkInitialConditions();


% Set up Blazer objects
here_setupDefaultBlazers();


% Define time frames and check for deficiency of simulation plans; can be
% done only after we expand the data for contributions
defineFrames(runningData, opt);


systemProperty = here_setupSystemProperty();
if ~isequal(opt.SystemProperty, false)
    outputDb = systemProperty;
    return
end

progress = [];
if opt.Progress
    progress = ProgressBar('[IrisToolbox] @Model/simulate Progress');
end


% 
% Update runningData.YXEPG once after running all pages/variants, storing
% the individual results in a temporary cell array; this is much faster
% than updating it in place in each run
%

%===========================================================================
numRuns = runningData.NumPages;
outputYXEPG = cell(1, numRuns);
for i = 1 : numRuns
    [~, outputYXEPG{i}] = simulateFrames(this, systemProperty, i, false);
    if opt.Progress
        update(progress, i/numRuns);
    end
end
runningData.YXEPG = cat(3, outputYXEPG{:});
%===========================================================================


if opt.Contributions
    here_postprocessContributions();
end

if isAsynchronous
    return
end

outputDb = here_createOutputData();

if runningData.PrepareOutputInfo
    outputInfo = here_createOutputInfo();
end

if runningData.PrepareFrameData
    frameDb = here_createFrameDb();
end

return

    function here_resolveContributionsConflicts()
        %(
        if opt.Contributions && plan.NumOfExogenizedPoints>0
            exception.error([
                "Model:CannotEvalContributionsWithExogenized"
                "Option Contributions=true cannot be used in simulations with exogenized variables." 
            ]);
        end
        if opt.Contributions && runningData.NumPages>1
            exception.error([
                "Model:CannotEvalContributionsWithMultipleDataSets"
                "Option Contributions=true cannot be used in simulations "
                "with multiple parameter variants or data pages."
            ]);
        end
        %)
    end%


    function here_copyOptionsToRunningData()
        %(
        numRuns = runningData.NumPages;
        runningData.Plan = plan;
        runningData.Window = opt.Window;
        runningData.SuccessOnly = opt.SuccessOnly;
        runningData.SparseShocks = opt.SparseShocks;
        runningData.Method = repmat(opt.Method, 1, numRuns);
        runningData.Deviation = repmat(opt.Deviation, 1, numRuns);
        runningData.SolverOptions = opt.Solver;
        %)
    end%


    function runningData = here_extractInputData(runningData)
        %(
        numDummyPeriods = here_calculateNumDummyPeriods();
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


        %
        % Retrieve data for variables from the input databank
        %
        % Defer parameters until simulateFrame because the model object is
        % changing in SystemProperty execution
        %
        [runningData.YXEPG, ~, extdRange, ~, runningData.MaxShift, runningData.TimeTrend] ...
            = data4lhsmrhs( ...
                this, inputDb, baseRangePlusDummy ...
                , "dbInfo", dbInfo ...
                , "resetShocks", true ...
                , "ignoreShocks", opt.IgnoreShocks ...
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
        runningData.Method = repmat(opt.Method, 1, numRuns);
        runningData.Deviation = repmat(opt.Deviation, 1, numRuns);
        %)
    end%


    function here_prepareContributions()
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

        if opt.Method==solver.Method.FIRSTORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            runningData.YXEPG(inxLog, :, end) = 1;
            runningData.YXEPG(~inxLog, :, end) = 0;
        end

        runningData.Method = repmat(solver.Method.FIRSTORDER, 1, numRuns);
        if opt.Method==solver.Method.FIRSTORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            runningData.Method(end) = solver.Method.NONE;
        else
            runningData.Method(end) = opt.Method;
        end
        runningData.Deviation = true(1, numRuns);
        runningData.Deviation(end-1:end) = opt.Deviation;
        %)
    end%


    function here_setupDefaultBlazers()
        %(
        switch opt.Method
            case solver.Method.STACKED
                defaultBlazer = solver.blazer.Stacked.forModel(this, opt);
                run(defaultBlazer);
                if opt.Blocks
                    exogenizedBlazer = solver.blazer.Stacked.forModel(this, opt);
                else
                    exogenizedBlazer = [];
                end
            case solver.Method.PERIOD
                defaultBlazer = solver.blazer.Period.forModel(this, opt);
                run(defaultBlazer);
                if opt.Blocks
                    exogenizedBlazer = solver.blazer.Period.forModel(this, opt);
                else
                    exogenizedBlazer = [];
                end
            case solver.Method.SELECTIVE
                defaultBlazer = solver.blazer.Selective();
                exogenizedBlazer = defaultBlazer;
            otherwise
                defaultBlazer = solver.blazer.FirstOrder();
                exogenizedBlazer = [];
        end
        runningData.DefaultBlazer = defaultBlazer;
        runningData.ExogenizedBlazer = exogenizedBlazer;
        %)
    end%


    function systemProperty = here_setupSystemProperty()
        %(
        systemProperty = SystemProperty(this);
        systemProperty.Function = @simulateFrames;
        systemProperty.MaxNumOfOutputs = 1;
        systemProperty.NamedReferences = cell(1, 1);
        systemProperty.NamedReferences{1} = this.Quantity.Name;
        systemProperty.CallerData = runningData;
        if isequal(opt.SystemProperty, false)
            systemProperty.OutputNames = cell(1, 0);
        else
            systemProperty.OutputNames = opt.SystemProperty;
        end
        %)
    end%


    function here_checkInitialConditions()
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


    function numDummyPeriods = here_calculateNumDummyPeriods()
        %(
        numDummyPeriods = opt.Window - 1;
        if ~strcmpi(opt.Method, 'FirstOrder')
            [~, maxShift] = getActualMinMaxShifts(this);
            numDummyPeriods = numDummyPeriods + maxShift;
        end
        if numDummyPeriods>0
            plan = extendWithDummies(plan, numDummyPeriods);
        end
        %)
    end%


    function outputDb = here_createOutputData()
        %(
        if startsWith(opt.OutputData, "databank", "ignoreCase", true)
            columns = 1 : runningData.BaseRangeColumns(end);
            startDate = runningData.ExtendedRange(1);
            outputDb = local_createOutputDb(this, runningData.YXEPG(:, columns, :), startDate, opt);
            if validate.databank(inputDb)
                outputDb = appendData(this, inputDb, outputDb, baseRange, opt);
            end
        else
            outputDb = runningData.YXEPG;
        end
        %)
    end%


    function outputInfo = here_createOutputInfo()
        %(
        outputInfo = struct();
        outputInfo.BaseRange = Dater(runningData.BaseRange);
        outputInfo.ExtendedRange = Dater(runningData.ExtendedRange);
        outputInfo.StartIterationsFrom = opt.StartIterationsFrom;
        outputInfo.Terminal = opt.Terminal;
        outputInfo.FrameColumns = runningData.FrameColumns;
        outputInfo.FrameDates = runningData.FrameDates;
        outputInfo.Success =  runningData.Success;
        outputInfo.ExitFlags = runningData.ExitFlags;
        outputInfo.DiscrepancyTables = runningData.DiscrepancyTables;
        outputInfo.ProgressBar = progress;
        %)
    end%


    function frameDb = here_createFrameDb()
        %(
        frameDb = cell(1, numRuns);
        for i = 1 : numRuns
            numFrames = size(runningData.FrameColumns{i}, 1);
            startDate = runningData.ExtendedRange(1);
            frameDb{i} = local_createOutputDb(this, runningData.FrameData{i}.YXEPG, startDate, opt);
        end
        %)
    end%


    function here_postprocessContributions()
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

function flag = local_validateSolverOption(x)
    %(
    flag = isequal(x, @auto) || isa(x, 'solver.Options') || local_validateSolverName(x) ...
           || (iscell(x) && local_validateSolverName(x{1}) && validate.nestedOptions(x(2:2:end)));
    if flag
        return
    end
    error("Input value must be valid solver settings.");
    %)
end%


function flag = local_validateSolverName(x)
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


function solverOption = local_parseSolverOption(solverOption, methodOption)
    %(
    if isa(solverOption, 'solver.Options') || isa(solverOption, 'optim.opt.SolverOptions')
        return
    end

    switch methodOption
        case solver.Method.FIRSTORDER
            solverOption = [];
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


function local_checkSolvedModel(this, method, initial, terminal)
    %(
    if ~needsFirstOrderSolution(method, this, initial, terminal) ...
        || all(beenSolved(this))
        return
    end
    exception.error([
        "Model:NeedsFirstOrderSolution"
        "Model simulation needs a valid first-order solution to be "
        "available given the opt Method, Initial and Terminal. "
    ]);
    %)
end%


function outputDb = local_createOutputDb(this, YXEPG, startDate, opt)
    %(
    if opt.Contributions
        comments = getLabelsForShockContributions(this.Quantity);
    else
        comments = getLabelsOrNames(this.Quantity);
    end

    inxInclude = ~getIndexByType(this.Quantity, 4);
    outputDb = databank.backend.fromArrayNoFrills( ...
        YXEPG ...
        , this.Quantity.Name ...
        , startDate ...
        , comments ...
        , inxInclude ...
        , opt.OutputType ...
        , opt.AddToDatabank ...
    );

    %
    % Include log of log-variables with LOG_PREFIX
    %
    inxLog = this.Quantity.InxLog;
    if opt.IncludeLog && any(inxLog)
        outputDb = databank.backend.fromArrayNoFrills( ...
            log(YXEPG(inxLog, :, :)) ...
            , string(this.Quantity.LOG_PREFIX) + textual.stringify(this.Quantity.Name(inxLog)) ...
            , startDate ...
            , "(Log) " + textual.stringify(comments(inxLog)) ...
            , inxInclude(inxLog) ...
            , opt.OutputType ...
            , outputDb ...
        );
    end

    if opt.AddParameters
        outputDb = addToDatabank("default", this, outputDb);
    end
    %)
end%


function terminal = local_resolveTerminal(terminal, method)
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


function plan = local_resolvePlan(this, baseRange, plan, anticipate)
    %(
    if isa(plan, 'Plan')
        if ~isempty(anticipate)
            here_throwError();
        end
        checkPlanConsistency(this, baseRange, plan);
        return
    end
    if islogical(plan)
        if ~isempty(anticipate)
            here_throwError();
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
        function here_throwError()
            exception.error([
                "Model:OptionsPlanAnticipate"
                "Options Plan= and Anticipate= cannot be used at the same time."
            ]);
        end%
    %)
end%


function local_validateAnticipateOption(x)
    %(
    if isempty(x) || isequal(x, true) || isequal(x, false)
        return
    end
    error("Input argument must be true or false.");
    %)
end%


function local_validatePlanOption(x)
    %(
    if isempty(x) || isequal(x, true) || isequal(x, false) || isa(x, 'Plan')
        return
    end
    error("Input argument must be true or false.");
    %)
end%


function local_validateSystemPropertyOption(x)
    %(
    if isequal(x, false) || validate.list(x)
        return
    end
    error("Input argument must be false or a list of names.");
    %)
end%


function local_validateLogOption(x)
    %(
    if isempty(x) || isequal(x, @all) || validate.list(x)
        return
    end
    error("Input argument must be empty, @all or a list of names.");
    %)
end%


function local_validateMethodOption(x)
    %(
    try
        solver.Method(string(x));
    catch
        error("Input argument must be a valid solver.Method.");
    end
    %)
end%


function local_validateWindowOption(x)
    %(
    if isequal(x, @auto) || validate.roundScalar(x, 1, Inf)
        return
    end
    error("Input argument must be @auto or a positive integer.");
    %)
end%


function local_validateInputDb(x)
    if validate.databank(x)
        return
    end
    if all(strcmpi(x, 'asynchronous'))
        return
    end
    error("Input value must be a databank.")
end%


function local_validateBaseRange(x)
    if isequal(x, @auto)
        return
    end
    if validate.properRange(x)
        return
    end
    error("Input value must be a date range.");
end%
