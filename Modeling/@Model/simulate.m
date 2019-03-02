function [outputData, outputInfo] = simulate(this, inputData, baseRange, varargin)

TYPE = @int8;

persistent parser
if isempty(parser)
    validateString = @(x, list) (ischar(x) || isa(x, 'string')) && any(strcmpi(x, list));
    parser = extend.InputParser('model.simulate');
    parser.addRequired('SolvedModel', @(x) isa(x, 'Model') && all(issolved(x)));
    parser.addRequired('InputData', @(x) isstruct(x) || isa(x, 'simulate.Data'));
    parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);

    parser.addDeviationOptions(false);
    parser.addParameter('Anticipate', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('AppendPostsample', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('AppendPresample', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Contributions', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('IgnoreShocks', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Method', solver.Method.FIRST_ORDER, @solver.Method.validate);
    parser.addParameter('OutputData', 'Databank', @(x) validateString(x, {'Databank', 'simulate.Data'}));
    parser.addParameter('Plan', true, @(x) isequal(x, true) || isequal(x, false) || isa(x, 'Plan'));
    parser.addParameter('ReturnNaNIfFailed', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Solver', @auto, @validateSolver);
    parser.addParameter('Window', @auto, @(x) isequal(x, @auto) || isequal(x, @max) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=1));

    parser.addParameter('Initial', 'Data', @(x) any(strcmpi(x, {'Data', 'FirstOrder'})));
    parser.addParameter('PrepareGradient', true, @(x) isequal(x, true) || isequal(x, false));
end
parser.parse(this, inputData, baseRange, varargin{:});
opt = parser.Options;
opt.EvalTrends = opt.DTrends;
usingDefaults = parser.UsingDefaultsInStruct;

baseRange = double(baseRange);
opt.Window = parseWindowOption(opt.Window, opt.Method, baseRange);
opt.Method = solver.Method.parse(opt.Method);
opt.Solver = parseSolverOption(opt.Solver, opt.Method);

%--------------------------------------------------------------------------

nv = length(this);

% Check the input databank; treat all names as optional, and check for
% missing initial conditions later
requiredNames = cell.empty(1, 0);
optionalNames = this.Quantity.Name;
databankInfo = checkInputDatabank(this, inputData, baseRange, requiredNames, optionalNames);

hereResolveOptionConflicts( );
plan = opt.Plan;

runningData = DynamicDataWrapper.withProperties( 'YXEPG', ...
                                                 'BaseRange', ...
                                                 'ExtendedRange', ...
                                                 'BaseRangeColumns', ...
                                                 'MaxShift', ...
                                                 'TimeTrend', ...
                                                 'NumOfDummyPeriods', ...
                                                 'TimeFrames', ...
                                                 'Success', ...
                                                 'ExitFlags' );

herePrepareRunningData( );

hereCheckInitialConditions( );

simulateTimeFrames(this, runningData, plan, opt);

outputData = herePrepareOutputData( );

if nargout>=2
    outputInfo = herePrepareOutputInfo( );
end

return
    



    function hereResolveOptionConflicts( )
        if ~usingDefaults.Anticipate && ~usingDefaults.Plan
            THIS_ERROR = { 'Model:CannotUseAnticipateAndPlan'
                           'Options Anticipate= and Plan= cannot be combined in one simulate(~)' };
            throw( exception.Base(THIS_ERROR, 'error') );
        end
        if ~usingDefaults.Anticipate && usingDefaults.Plan
            opt.Plan = opt.Anticipate;
        end
        if ~isa(opt.Plan, 'Plan')
            opt.Plan = Plan(this, baseRange, 'Anticipate=', opt.Plan);
        else
            checkCompatibilityOfPlan(this, baseRange, opt.Plan);
        end
        if opt.Contributions && opt.Plan.NumOfExogenizedPoints>0
            THIS_ERROR = { 'Model:CannotEvalContributionsWithExogenized'
                           'Option Contributions=true cannot be used in simulations with exogenized variables' }
            throw( exception.Base(THIS_ERROR, 'error') );
        end
        if opt.Contributions && databankInfo.NumOfDataSets>1
            THIS_ERROR = { 'Model:CannotEvalContributionsWithMultipleDataSets'
                           'Option Contributions=true cannot be used in simulations on multiple data sets' }
            throw( exception.Base(THIS_ERROR, 'error') );
        end
    end%




    function herePrepareRunningData( )
        herePrepareDummyPeriods( );
        numOfDummyPeriods = runningData.NumOfDummyPeriods;
        startOfBaseRange = baseRange(1);
        endOfBaseRange = baseRange(end);
        endOfBaseRangePlusDummy = endOfBaseRange + numOfDummyPeriods;
        baseRangePlusDummy = [startOfBaseRange, endOfBaseRangePlusDummy];
        runningData.BaseRange = [startOfBaseRange, endOfBaseRange];
        [ runningData.YXEPG, ~, ...
          extendedRange, ~, ...
          runningData.MaxShift, ...
          runningData.TimeTrend ] = data4lhsmrhs( this, ...
                                                  inputData, ...
                                                  baseRangePlusDummy, ...
                                                  'ResetShocks=', true, ...
                                                  'IgnoreShocks=', opt.IgnoreShocks, ...
                                                  'NumOfDummyPeriods', numOfDummyPeriods );
        startOfExtendedRange = extendedRange(1);
        endOfExtendedRange = extendedRange(end);
        runningData.ExtendedRange = [startOfExtendedRange, endOfExtendedRange];
        runningData.BaseRangeColumns = [ round(startOfBaseRange - startOfExtendedRange + 1), ...
                                         round(endOfBaseRange - startOfExtendedRange + 1) ];
        numOfDataSets = size(runningData.YXEPG, 3); 
        if numOfDataSets==1 && nv>1
            % Expand number of data sets to match number of parameter variants
            runningData.YXEPG = repmat(runningData.YXEPG, 1, 1, numOfRuns);
        end
    end%


    

    function hereCheckInitialConditions( )
        % Report missing initial conditions
        firstColumnOfSimulation = runningData.BaseRangeColumns(1);
        inxOfNaNPresample = any(isnan(runningData.YXEPG(:, 1:firstColumnOfSimulation-1, :)), 3);
        checkInitialConditions(this, inxOfNaNPresample, firstColumnOfSimulation);
    end%




    function numOfDummyPeriods = herePrepareDummyPeriods( )
        numOfDummyPeriods = opt.Window - 1;
        if ~strcmpi(opt.Method, 'FirstOrder')
            [~, maxShift] = getActualMinMaxShifts(this);
            numOfDummyPeriods = numOfDummyPeriods + maxShift;
        end
        if numOfDummyPeriods>0
            plan = extendWithDummies(plan, numOfDummyPeriods);
        end
        runningData.NumOfDummyPeriods = numOfDummyPeriods;
    end%




    function outputData = herePrepareOutputData( )
        if strcmpi(opt.OutputData, 'Databank')
            if opt.Contributions
                comments = this.Quantity.Label4ShockContributions;
            else
                comments = this.Quantity.LabelOrName;
            end
            inxToInclude = ~getIndexByType(this.Quantity, TYPE(4));
            baseRange = runningData.BaseRange;
            startOfExtendedRange = runningData.ExtendedRange(1);
            lastColumnOfSimulation = runningData.BaseRangeColumns(end);
            outputData = databank.fromDoubleArrayNoFrills( runningData.YXEPG(:, 1:lastColumnOfSimulation, :), ...
                                                           this.Quantity.Name, ...
                                                           startOfExtendedRange, ...
                                                           comments, ...
                                                           inxToInclude );
            outputData = addToDatabank('Default', this, outputData);
            outputData = appendData(this, inputData, outputData, baseRange, opt);
        else
            outputData = runningData.YXEPG;
        end
    end%




    function outputInfo = herePrepareOutputInfo( )
        timeFrames = runningData.TimeFrames;
        numOfRuns = numel(timeFrames);
        for run = 1 : numOfRuns
            numOfTimeFrames = size(timeFrames{run});
            extendedRange = runningData.ExtendedRange;
            startOfExtendedRange = extendedRange(1);
            endOfExtendedRange = extendedRange(end);
            for frame = 1 : numOfTimeFrames
                startOfTimeFrame = startOfExtendedRange + timeFrames{run}(frame, 1) - 1;
                endOfTimeFrame = startOfExtendedRange + timeFrames{run}(frame, 2) - 1;
                timeFrames{run}(frame, :) = [startOfTimeFrame, endOfTimeFrame];
            end
            timeFrames{run} = DateWrapper.fromDateCode(timeFrames{run});
        end
        outputInfo = struct( );
        outputInfo.TimeFrames = timeFrames;
        outputInfo.BaseRange = DateWrapper.fromDateCode(runningData.BaseRange);
        outputInfo.ExtendedRange = DateWrapper.fromDateCode(runningData.ExtendedRange);
        outputInfo.Success =  runningData.Success;
        outputInfo.ExitFlags = runningData.ExitFlags;
    end%
end%


%
% Local Functions
%


function flag = validateMethod(x)
    validateString = @(x, list) (ischar(x) || isa(x, 'string')) && any(strcmpi(x, list));
    listOfMethods = {'FirstOrder', 'Selective', 'Stacked', 'NoForward'};
    if validateString(x, listOfMethods)
        flag = true;
    end    
    if iscell(x) && ~isempty(x) ...
       && validateString(x{1}, listOfMethods) ...
       && iscellstr(x(2:2:end))
        flag = true;
    end
    flag = false; 
end%




function flag = validateSolver(x)
    flag = isequal(x, @auto) || isa(x, 'solver.Options') || validateSolverName(x) ...
           || (iscell(x) && validateSolverName(x{1}) && iscellstr(x(2:2:end)));
end%




function flag = validateSolverName(x)
    if ~ischar(x) && ~isa(x, 'string') && ~isa(x, 'function_handle')
        flag = false;
        return
    end
    listOfSolverNames = { 'auto' 
                          'IRIS-QaD'
                          'IRIS-Newton'
                          'IRIS-Qnsd'
                          'QaD'
                          'IRIS'
                          'lsqnonlin'
                          'fsolve'      };
    flag = any(strcmpi(char(x), listOfSolverNames));
end%




function windowOption = parseWindowOption(windowOption, methodOption, baseRange)
    if isequal(windowOption, @auto)
        if methodOption==solver.Method.FIRST_ORDER
            windowOption = 1;
        else
            windowOption = @max;
        end
    end
    lenOfBaseRange = round(baseRange(end) - baseRange(1) + 1);
    if isequal(windowOption, @max)
        windowOption = lenOfBaseRange;
    elseif isnumeric(windowOption) && windowOption>lenOfBaseRange
        THIS_ERROR = { 'Model:WindowCannotExceedRangeLength'
                       'Simulation windowOption cannot exceed number of simulation periods' };
        throw( exception.Base(THIS_ERROR, 'error') );
    end
end%




function solverOption = parseSolverOption(solverOption, methodOption)
    switch methodOption
        case solver.Method.FIRST_ORDER
            solverOption = [ ];
        case solver.Method.SELECTIVE
            defaultSolver = 'IRIS-QaD';
            prepareGradient = false;
            displayMode = 'Verbose';
            solverOption = solver.Options.parseOptions( solverOption, ...
                                                        defaultSolver, ...
                                                        prepareGradient, ...
                                                        displayMode );
        case {solver.Method.STACKED, solver.Method.STATIC}
            defaultSolver = 'IRIS-Newton';
            prepareGradient = false;
            displayMode = 'Verbose';
            solverOption = solver.Options.parseOptions( solverOption, ...
                                                        defaultSolver, ...
                                                        prepareGradient, ...
                                                        displayMode );
    end
end%

