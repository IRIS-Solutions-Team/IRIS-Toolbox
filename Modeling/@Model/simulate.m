% simulate  Simulate model
%{
%
% ## Syntax ##
%
%     [outputDb, outputInfo] = simulate(model, inputDb, range, ...)
%
%
% Input Arguments
%-----------------
%
%
% __`model`__ [ Model ]
% > 
% Model object with a valid solution avalaible for each of its parameter variants.
%
%
% __`inputDb`__ [ struct | Dictionary ]
% >
% Databank (struct or Dictionary) with initial conditions, shocks, and
% exogenized data points for the simulation.
%
%
% __`range`__ [ DateWrapper | numeric ]
% >
% Simulation range; only the start date (the first element in `range`) and
% the end date (the last element in `range`) are considered.
%
%
% Output Arguments
%------------------
%
% __`outputDb`__ [ struct | Dictionary ]
% >
% Databank (struct or Dictionary) with the simulation results; if options
% `PrependInput=` or `AppendInput=` are not used, the time series in
% `outputDb` span the simulation `range` plus all necessary initial
% conditions for those variables that have lags in the model.
%
%
% ## Options ##
%
%
% ## Description ##
%
%
% ## Example ##
%
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [outputDb, outputInfo] = simulate(this, inputDb, baseRange, varargin)

TYPE = @int8;

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('model.simulate');

    addRequired(pp, 'solvedModel', @(x) isa(x, 'Model'));
    addRequired(pp, 'inputDb', @(x) validate.databank(x) || isa(x, 'simulate.Data') || isequal(x, "asynchronous"));
    addRequired(pp, 'simulationRange', @(x) DateWrapper.validateProperRangeInput(x) || isequal(x, @auto));

    addDeviationOptions(pp, false);
    addParameter(pp, 'Anticipate', true, @validate.logicalScalar);
    addParameter(pp, {'AppendPostsample', 'AppendInput'}, false, @validate.logicalScalar);
    addParameter(pp, {'AppendPresample', 'PrependInput'}, false, @validate.logicalScalar);
    addParameter(pp, 'Contributions', false, @validate.logicalScalar);
    addParameter(pp, 'IgnoreShocks', false, @validate.logicalScalar);
    addParameter(pp, 'Method', solver.Method.FIRST_ORDER, @solver.Method.validate);
    addParameter(pp, 'OutputData', 'Databank', @(x) validateString(x, {'Databank', 'simulate.Data'}));
    addParameter(pp, 'OutputType', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'struct', 'Dictionary'));
    addParameter(pp, 'Plan', true, @(x) validate.logicalScalar(x) || isa(x, 'Plan'));
    addParameter(pp, 'Progress', false, @validate.logicalScalar);
    addParameter(pp, 'SuccessOnly', false, @validate.logicalScalar);
    addParameter(pp, 'Solver', @auto, @validateSolver);
    addParameter(pp, 'SparseShocks', false, @validate.logicalScalar)
    addParameter(pp, 'SystemProperty', false, @(x) isequal(x, false) || validate.list(x));
    addParameter(pp, 'Window', @auto, @(x) isequal(x, @auto) || isequal(x, @max) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=1));

    addParameter(pp, 'Initial', 'Data', @(x) validate.anyString(x, 'Data', 'FirstOrder'));
    addParameter(pp, 'PrepareGradient', true, @validate.logicalScalar);
end
%)
opt = parse(pp, this, inputDb, baseRange, varargin{:});
opt.EvalTrends = opt.DTrends;
usingDefaults = pp.UsingDefaultsInStruct;

if ~isequal(baseRange, @auto)
    baseRange = double(baseRange);
end

opt.Method = solver.Method.parse(opt.Method);
if opt.Method==solver.Method.SELECTIVE && ~any(this.Equation.InxOfHashEquations)
    opt.Method = solver.Method.FIRST_ORDER;
    exception.warning([
        "Model:FirstOrderInsteadSelective"
        "The model has no hash equations; switching from Method=Selective "
        "to Method=FirstOrder. "
    ]);
end

[opt.Window, baseRange] = resolveWindowAndBaseRange(opt.Window, opt.Method, baseRange);
opt.Solver = parseSolverOption(opt.Solver, opt.Method);
isAsynchronous = isequal(inputDb, "asynchronous");
opt.Solver = hereResolveSolverOption(opt.Solver);

%--------------------------------------------------------------------------

%
% All simulation methods except PERIOD require a solved Model
%
locallyCheckSolvedModel(this, opt.Method);

nv = countVariants(this);

% Check the input databank; treat all names as optional, and check for
% missing initial conditions later
requiredNames = string.empty(1, 0);
optionalNames = this.Quantity.Name(this.Quantity.Type~=TYPE(4));
dbInfo = checkInputDatabank( ...
    this, inputDb, baseRange, requiredNames, optionalNames ...
);

plan = hereResolvePlan( );

%
% Prepare running data
%
runningData = simulate.InputOutputData( );
runningData.InxE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
runningData.IsAsynchronous = isAsynchronous;
runningData.PrepareOutputInfo = nargout>=2;

% Retrieve data from intput databank, set up ranges
herePrepareData( );

% Check Contributions= only after preparing data and resolving the number
% of runs (variants, pages)
hereResolveContributionsConflicts( );

hereCopyOptionsToRunningData( );

if opt.Contributions
    % Expand and set up YXEPG to prepare contributions simulation
    herePrepareContributions( );
end

% Define time frames and check for deficiency of simulation plans; can be
% done only after we expand the data for contributions
defineFrames(runningData);

% Check initial conditions for NaNs
hereCheckInitialConditions( );

herePrepareBlazer( );

systemProperty = hereSetupSystemProperty( );
if ~isequal(opt.SystemProperty, false)
    outputDb = systemProperty;
    return
end

progress = [ ];
if opt.Progress
    progress = ProgressBar('[IrisToolbox] @Model/simulate Progress');
end


% /////////////////////////////////////////////////////////////////////////
numRuns = runningData.NumOfPages;
for i = 1 : numRuns
    simulateFrames(this, systemProperty, i);
    if opt.Progress
        update(progress, i/numRuns);
    end
end
% /////////////////////////////////////////////////////////////////////////


if opt.Contributions
    herePostprocessContributions( );
end

if isAsynchronous
    return
end

outputDb = hereCreateOutputData( );
outputInfo = herePrepareOutputInfo( );

return

    function plan = hereResolvePlan( )
        %(
        plan = opt.Plan;
        if ~usingDefaults.Anticipate && ~usingDefaults.Plan
            thisError = [
                "Model:CannotUseAnticipateAndPlan"
                "Options Anticipate= and Plan= cannot be combined in one simulation."
            ];
            throw(exception.Base(thisError, 'error'));
        end
        if ~usingDefaults.Anticipate && usingDefaults.Plan
            plan = opt.Anticipate;
        end
        if ~isa(plan, 'Plan')
            plan = Plan(this, baseRange, 'Anticipate=', plan);
        else
            checkCompatibilityOfPlan(this, baseRange, plan);
        end
        %)
    end%


    function hereResolveContributionsConflicts( )
        %(
        if opt.Contributions && plan.NumOfExogenizedPoints>0
            thisError = [
                "Model:CannotEvalContributionsWithExogenized"
                "Option Contributions=true cannot be used in simulations with exogenized variables." 
            ];
            throw(exception.Base(thisError, 'error'));
        end
        if opt.Contributions && runningData.NumOfPages>1
            thisError = [
                "Model:CannotEvalContributionsWithMultipleDataSets"
                "Option Contributions=true cannot be used in simulations "
                "with multiple parameter variants or data pages."
            ];
            throw(exception.Base(thisError, 'error'));
        end
        %)
    end%


    function hereCopyOptionsToRunningData( )
        %(
        numRuns = runningData.NumOfPages;
        runningData.Plan = plan;
        runningData.Initial = opt.Initial;
        runningData.Window = opt.Window;
        runnintDaga.SuccessOnly = opt.SuccessOnly;
        runningData.SparseShocks = opt.SparseShocks;
        runningData.SolverOptions = opt.Solver;
        runningData.Method = repmat(opt.Method, 1, numRuns);
        runningData.Deviation = repmat(opt.Deviation, 1, numRuns);
        runningData.NeedsEvalTrends = repmat(opt.EvalTrends, 1, numRuns);
        %)
    end%


    function herePrepareData( )
        %(
        numDummyPeriods = hereCalculateNumDummyPeriods( );
        baseStart = baseRange(1);
        baseEnd = baseRange(end);
        endBaseRangePlusDummy = baseEnd + numDummyPeriods;
        baseRangePlusDummy = [baseStart, endBaseRangePlusDummy];
        [ ... 
            runningData.YXEPG, ~, extdRange, ~ ...
            , runningData.MaxShift, runningData.TimeTrend ...
            , dbInfo ...
        ] = data4lhsmrhs( ...
            this, inputDb, baseRangePlusDummy ...
            , 'ResetShocks=', true ...
            , 'IgnoreShocks=', opt.IgnoreShocks ...
            , 'NumDummyPeriods', numDummyPeriods ...
        );
        extdStart = extdRange(1);
        extdEnd = extdRange(end);
        runningData.ExtendedRange = [extdStart, extdEnd];
        runningData.BaseRangeColumns = colon( round(baseStart - extdStart + 1), ...
                                              round(baseEnd - extdStart + 1) );
        numPages = runningData.NumOfPages;
        if numPages==1 && nv>1
            % Expand number of data sets to match number of parameter variants
            runningData.YXEPG = repmat(runningData.YXEPG, 1, 1, nv);
        end
        numRuns = runningData.NumOfPages;
        runningData.InxOfInitInPresample = getInxOfInitInPresample(this, runningData.BaseRangeColumns(1));
        runningData.Method = repmat(opt.Method, 1, numRuns);
        runningData.Deviation = repmat(opt.Deviation, 1, numRuns);
        runningData.NeedsEvalTrends = repmat(opt.EvalTrends, 1, numRuns);
        %)
    end%


    function herePrepareContributions( )
        %(
        firstColumnToSimulate = runningData.BaseRangeColumns(1);
        inxLog = this.Quantity.InxLog;
        inxE = getIndexByType(this, TYPE(31), TYPE(32));
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

        if opt.Method==solver.Method.FIRST_ORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            runningData.YXEPG(inxLog, :, end) = 1;
            runningData.YXEPG(~inxLog, :, end) = 0;
        end

        runningData.Method = repmat(solver.Method.FIRST_ORDER, 1, numRuns);
        if opt.Method==solver.Method.FIRST_ORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            runningData.Method(end) = solver.Method.NONE;
        else
            runningData.Method(end) = opt.Method;
        end
        runningData.Deviation = true(1, numRuns);
        runningData.Deviation(end-1:end) = opt.Deviation;
        runningData.NeedsEvalTrends = false(1, numRuns);
        runningData.NeedsEvalTrends(end-1:end) = opt.EvalTrends;
        %)
    end%


    function herePrepareBlazer( )
        %(
        firstColumnToRun = runningData.BaseRangeColumns(1);
        lastColumnToRun = runningData.BaseRangeColumns(end);
        switch opt.Method
            case {solver.Method.STACKED, solver.Method.PERIOD}
                blazer = prepareBlazer(this, opt.Method, opt);
                blazer.ColumnsToRun = firstColumnToRun : lastColumnToRun;
                run(blazer, opt);
                prepareForSolver(blazer, opt);

                opt.Blocks = false;
                blazerNoBlocks = prepareBlazer(this, opt.Method, opt);
                blazerNoBlocks.ColumnsToRun = firstColumnToRun : lastColumnToRun;
                run(blazerNoBlocks, opt);
                prepareForSolver(blazer, opt);
                opt.Blocks = true;

                runningData.Blazers = [blazerNoBlocks, blazer];
            otherwise
                runningData.Blazers = [ ];
        end
        %)
    end%


    function systemProperty = hereSetupSystemProperty( )
        %(
        systemProperty = SystemProperty(this);
        systemProperty.Function = @simulateFrames;
        systemProperty.MaxNumOfOutputs = 1;
        systemProperty.NamedReferences = cell(1, 1);
        systemProperty.NamedReferences{1} = this.Quantity.Name;
        systemProperty.Specifics = runningData;
        if isequal(opt.SystemProperty, false)
            systemProperty.OutputNames = cell(1, 0);
        else
            systemProperty.OutputNames = opt.SystemProperty;
        end
        %)
    end%


    function hereCheckInitialConditions( )
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


    function numDummyPeriods = hereCalculateNumDummyPeriods( )
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


    function outputDb = hereCreateOutputData( )
        %(
        if strcmpi(opt.OutputData, 'Databank')
            if opt.Contributions
                comments = this.Quantity.Label4ShockContributions;
            else
                comments = this.Quantity.LabelOrName;
            end
            inxInclude = ~getIndexByType(this.Quantity, TYPE(4));
            baseRange = runningData.BaseRange;
            extdStart = runningData.ExtendedRange(1);
            lastColumnSimulation = runningData.BaseRangeColumns(end);
            timeSeriesConstructor = @default;
            outputDb = databank.backend.fromDoubleArrayNoFrills( ...
                runningData.YXEPG(:, 1:lastColumnSimulation, :), ...
                this.Quantity.Name, ...
                extdStart, ...
                comments, ...
                inxInclude, ...
                timeSeriesConstructor, ...
                opt.OutputType ...
            );
            outputDb = addToDatabank('Default', this, outputDb);
            if validate.databank(inputDb)
                outputDb = appendData(this, inputDb, outputDb, baseRange, opt);
            end
        else
            outputDb = runningData.YXEPG;
        end
        %)
    end%


    function outputInfo = herePrepareOutputInfo( )
        %(
        outputInfo = struct( );
        if ~runningData.PrepareOutputInfo
            return
        end
        outputInfo.Frames = runningData.Frames;
        outputInfo.FrameDates = runningData.FrameDates;
        outputInfo.BaseRange = DateWrapper(runningData.BaseRange);
        outputInfo.ExtendedRange = DateWrapper(runningData.ExtendedRange);
        outputInfo.Success =  runningData.Success;
        outputInfo.ExitFlags = runningData.ExitFlags;
        outputInfo.DiscrepancyTables = runningData.DiscrepancyTables;
        outputInfo.ProgressBar = progress;
        %)
    end%


    function herePostprocessContributions( )
        %(
        inxLog = this.Quantity.InxLog;
        if opt.Method~=solver.Method.FIRST_ORDER
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


function flag = validateMethod(x)
    %(
    listOfMethods = {'FirstOrder', 'Selective', 'Stacked', 'NoForward'};
    if validate.anyString(x, listOfMethods{:})
        flag = true;
    end    
    if iscell(x) && ~isempty(x) ...
       && validate.anyString(x{1}, listOfMethods{:}) ...
       && iscellstr(x(2:2:end))
        flag = true;
    end
    flag = false; 
    %)
end%


function flag = validateSolver(x)
    %(
    flag = isequal(x, @auto) || isa(x, 'solver.Options') || validateSolverName(x) ...
           || (iscell(x) && validateSolverName(x{1}) && iscellstr(x(2:2:end)));
    %)
end%


function flag = validateSolverName(x)
    %(
    if ~ischar(x) && ~isa(x, 'string') && ~isa(x, 'function_handle')
        flag = false;
        return
    end
    listSolverNames = { 
        'auto' 
        'IRIS-QaD'
        'IRIS-Newton'
        'IRIS-Qnsd'
        'QaD'
        'IRIS'
        'fminsearch'
        'lsqnonlin'
        'fsolve'      
    };
    flag = any(strcmpi(char(x), listSolverNames));
    %)
end%


function solverOption = hereResolveSolverOption(solverOption)
    %(
    if ischar(solverOption) || isstring(solverOption)
        solverName = solverOption;
        keep = cell.empty(1, 0);
    elseif iscell(solverOption)
        solverName = solverOption{1};
        keep = solverOption(2:end);
    else
        return
    end
    if strcmpi(solverName, 'fminsearch')
        solverOption = optimset(keep{:});
        solverOption.SolverName = 'fminsearch';
    end
    %)
end%


function [windowOption, baseRange] = resolveWindowAndBaseRange(windowOption, methodOption, baseRange)
    %(
    if isequal(baseRange, @auto)
        if isequal(windowOption, @auto) || isequal(windowOption, @max)
            baseRange = 1;
            windowOption = 1;
            return
        else
            baseRange = 1 : windowOption;
            return
        end
    end

    if isequal(windowOption, @auto)
        if methodOption==solver.Method.FIRST_ORDER
            windowOption = 1;
        else
            windowOption = @max;
        end
    end
    lenBaseRange = round(baseRange(end) - baseRange(1) + 1);
    if isequal(windowOption, @max)
        windowOption = lenBaseRange;
    elseif isnumeric(windowOption) && windowOption>lenBaseRange
        thisError = [
            "Model:WindowCannotExceedRangeLength"
            "Simulation windowOption cannot exceed number of simulation periods" 
        ];
        throw(exception.Base(thisError, 'error'));
    end
    %)
end%


function solverOption = parseSolverOption(solverOption, methodOption)
    %(
    switch methodOption
        case solver.Method.FIRST_ORDER
            solverOption = [ ];
        case solver.Method.SELECTIVE
            defaultSolver = 'IRIS-QaD';
            prepareGradient = false;
            displayMode = 'Verbose';
            solverOption = solver.Options.parseOptions( ...
                solverOption, defaultSolver, prepareGradient, displayMode ...
            );
        case {solver.Method.STACKED, solver.Method.PERIOD}
            defaultSolver = 'IRIS-Newton';
            prepareGradient = false;
            displayMode = 'Verbose';
            solverOption = solver.Options.parseOptions( ...
                solverOption, defaultSolver, prepareGradient, displayMode ...
            );
    end
    %)
end%


function locallyCheckSolvedModel(this, method)
    %(
    if method==solver.Method.PERIOD || validate.solvedModel(this)
        return
    end
    thisError = [
        "Model:NeedsSolvedModel"
        "The Model must be solved first before running a simulation "
        "with Method=%s."
    ];
    throw(exception.Base(thisError, 'error'), method);
    %)
end%

