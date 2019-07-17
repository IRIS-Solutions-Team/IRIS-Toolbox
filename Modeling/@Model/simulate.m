function [outputData, outputInfo] = simulate(this, inputData, baseRange, varargin)
% simulate  Simulate model
%{
%
% ## Syntax ##
%
%     [outputDatabank, outputInfo] = simulate(model, inputDatabank, range, ...)
%
%
% ## Input Arguments ##
%
% * `model` [ Model ] - Model object with a solution avalaibl for each of
% its parameter variants.
%
% * `inputDatabank` [ struct ] - Databank (struct) with initial conditions,
% shocks, and exogenized data points for the simulation.
%
% * `range` [ DateWrapper | numeric ] - Simulation range; only the start
% date (the first element in `range`) and the end date (the last element in
% `range`) are considered.
%
%
% ## Output Arguments ##
%
% * `outputDatabank` [ struct ] - Databank (struct) with the simulation
% results; if options `AppendPresample=` or `AppendPostsample=` are not
% used, the time series in `outputDatabank` span the simulation `range`
% plus all necessary initial conditions for those variables that have lags
% in the model.
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.simulate');
    parser.addRequired('SolvedModel', @Valid.solvedModel);
    parser.addRequired('InputData', @(x) isstruct(x) || isa(x, 'simulate.Data'));
    parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);

    parser.addDeviationOptions(false);
    parser.addParameter('Anticipate', true, @Valid.logicalScalar);
    parser.addParameter('AppendPostsample', false, @Valid.logicalScalar);
    parser.addParameter('AppendPresample', false, @Valid.logicalScalar);
    parser.addParameter('Contributions', false, @Valid.logicalScalar);
    parser.addParameter('Homotopy', [ ], @(x) isempty(x) || isstruct(x));
    parser.addParameter('IgnoreShocks', false, @Valid.logicalScalar);
    parser.addParameter('Method', solver.Method.FIRST_ORDER, @solver.Method.validate);
    parser.addParameter('OutputData', 'Databank', @(x) validateString(x, {'Databank', 'simulate.Data'}));
    parser.addParameter('Plan', true, @(x) Valid.logicalScalar(x) || isa(x, 'Plan'));
    parser.addParameter('ProgressInfo', false, @Valid.logicalScalar);
    parser.addParameter('SuccessOnly', false, @Valid.logicalScalar);
    parser.addParameter('Solver', @auto, @validateSolver);
    parser.addParameter('SparseShocks', false, @Valid.logicalScalar)
    parser.addParameter('SystemProperty', false, @(x) isequal(x, false) || Valid.list(x));
    parser.addParameter('Window', @auto, @(x) isequal(x, @auto) || isequal(x, @max) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=1));

    parser.addParameter('Initial', 'Data', @(x) Valid.anyString(x, 'Data', 'FirstOrder'));
    parser.addParameter('PrepareGradient', true, @Valid.logicalScalar);
end
parse(parser, this, inputData, baseRange, varargin{:});
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

% __Prepare Running Data__
runningData = simulate.InputOutputData( );
runningData.PrepareOutputInfo = nargout>=2;

% Retrieve data from intput databank, set up ranges
herePrepareData( );

hereCopyOptionsToRunningData( );

if opt.Contributions
    % Expand and set up YXEPG to prepare contributions simulation
    herePrepareContributions( );
end

% Define time frames; can be done only after we expand the data for
% contributions
herePrepareTimeFrames( );

% Check initial conditions for NaNs
hereCheckInitialConditions( );

herePrepareBlazer( );

systemProperty = hereSetupSystemProperty( );

if ~isequal(opt.SystemProperty, false)
    outputData = systemProperty;
    return
end

progressInfo = ProgressInfo.empty(0);
if opt.ProgressInfo
    herePrepareProgressInfo( );
end


% /////////////////////////////////////////////////////////////////////////
numOfRuns = runningData.NumOfPages;
for i = 1 : numOfRuns
    simulateTimeFrames(this, systemProperty, i);
    if opt.ProgressInfo
        hereUpdateProgressInfo(i);
    end
end
% /////////////////////////////////////////////////////////////////////////


if opt.Contributions
    herePostprocessContributions( );
end

outputData = hereCreateOutputData( );

if runningData.PrepareOutputInfo
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
        if opt.Contributions && databankInfo.NumOfPages>1
            THIS_ERROR = { 'Model:CannotEvalContributionsWithMultipleDataSets'
                           'Option Contributions=true cannot be used in simulations on multiple data sets' }
            throw( exception.Base(THIS_ERROR, 'error') );
        end
    end%




    function hereCopyOptionsToRunningData( )
        numOfRuns = runningData.NumOfPages;
        runningData.Plan = plan;
        runningData.Initial = opt.Initial;
        runningData.Window = opt.Window;
        runnintDaga.SuccessOnly = opt.SuccessOnly;
        runningData.SparseShocks = opt.SparseShocks;
        runningData.Solver = opt.Solver;
        runningData.Method = repmat(opt.Method, 1, numOfRuns);
        runningData.Deviation = repmat(opt.Deviation, 1, numOfRuns);
        runningData.NeedsEvalTrends = repmat(opt.EvalTrends, 1, numOfRuns);
    end%




    function herePrepareData( )
        TYPE = @int8;
        numOfDummyPeriods = hereCalculateNumOfDummyPeriods( );
        runningData.NumOfDummyPeriods = numOfDummyPeriods;
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
        runningData.BaseRangeColumns = colon( round(startOfBaseRange - startOfExtendedRange + 1), ...
                                              round(endOfBaseRange - startOfExtendedRange + 1) );
        numOfPages = runningData.NumOfPages;
        if numOfPages==1 && nv>1
            % Expand number of data sets to match number of parameter variants
            runningData.YXEPG = repmat(runningData.YXEPG, 1, 1, nv);
        end
        numOfRuns = runningData.NumOfPages;
        runningData.InxOfInitInPresample = getInxOfInitInPresample(this, runningData.BaseRangeColumns(1));
        runningData.Method = repmat(opt.Method, 1, numOfRuns);
        runningData.Deviation = repmat(opt.Deviation, 1, numOfRuns);
        runningData.NeedsEvalTrends = repmat(opt.EvalTrends, 1, numOfRuns);
    end%




    function herePrepareContributions( )
        firstColumnToSimulate = runningData.BaseRangeColumns(1);
        inxOfLog = this.Quantity.InxOfLog;
        inxOfE = getIndexByType(this, TYPE(31), TYPE(32));
        posOfE = find(inxOfE);
        numOfE = nnz(inxOfE);
        numOfRuns = numOfE + 2;
        runningData.YXEPG = repmat(runningData.YXEPG, 1, 1, numOfRuns);
        % Zero out initial conditions in shock contributions
        runningData.YXEPG(inxOfLog, 1:firstColumnToSimulate-1, 1:numOfE) = 1;
        runningData.YXEPG(~inxOfLog, 1:firstColumnToSimulate-1, 1:numOfE) = 0;
        for ii = 1 : numOfE
            temp = runningData.YXEPG(posOfE(ii), :, ii);
            runningData.YXEPG(inxOfE, :, ii) = 0;
            runningData.YXEPG(posOfE(ii), :, ii) = temp;
        end
        % Zero out all shocks in init+const contributions
        runningData.YXEPG(inxOfE, firstColumnToSimulate:end, end-1) = 0;

        if opt.Method==solver.Method.FIRST_ORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            runningData.YXEPG(inxOfLog, :, end) = 1;
            runningData.YXEPG(~inxOfLog, :, end) = 0;
        end

        runningData.Method = repmat(solver.Method.FIRST_ORDER, 1, numOfRuns);
        if opt.Method==solver.Method.FIRST_ORDER 
            % Assign zero contributions of nonlinearities right away if
            % this is a first order simulation
            runningData.Method(end) = solver.Method.NONE;
        else
            runningData.Method(end) = opt.Method;
        end
        runningData.Deviation = true(1, numOfRuns);
        runningData.Deviation(end-1:end) = opt.Deviation;
        runningData.NeedsEvalTrends = false(1, numOfRuns);
        runningData.NeedsEvalTrends(end-1:end) = opt.EvalTrends;
    end%




    function timeFrameDates = herePrepareTimeFrames( )
        numOfPages = runningData.NumOfPages;
        inxOfE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
        runningData.TimeFrames = cell(1, numOfPages);
        runningData.MixinUnanticipated = false(1, numOfPages);
        runningData.TimeFrameDates = cell(1, numOfPages);
        extendedRange = runningData.ExtendedRange;
        startOfExtendedRange = extendedRange(1);
        endOfExtendedRange = extendedRange(end);
        deficiency = cell(1, numOfPages);
        for page = 1 : numOfPages
            [~, unanticipatedE] = simulate.Data.splitE( runningData.YXEPG(inxOfE, :, page), ...
                                                        plan.AnticipationStatusOfExogenous, ...
                                                        runningData.BaseRangeColumns );
            [ runningData.TimeFrames{page}, ...
              runningData.MixinUnanticipated(page) ] = ...
                splitIntoTimeFrames( unanticipatedE, ...
                                     runningData.BaseRangeColumns, ...
                                     plan, ...
                                     runningData.MaxShift, ...
                                     opt );
            numOfTimeFrames = size(runningData.TimeFrames{page}, 1);
            timeFrameDates = nan(numOfTimeFrames, 2);
            deficiency{page} = zeros(1, numOfTimeFrames);
            for frame = 1 : numOfTimeFrames
                startOfTimeFrame = startOfExtendedRange + runningData.TimeFrames{page}(frame, 1) - 1;
                endOfTimeFrame = startOfExtendedRange + runningData.TimeFrames{page}(frame, end) - 1;
                timeFrameDates(frame, :) = [startOfTimeFrame, endOfTimeFrame];
                % Check determinacy of simulation plan within this time frame
                deficiency{page}(frame) = hereCheckDeterminacyOfPlan( );
            end
            runningData.TimeFrameDates{page} = DateWrapper.fromDateCode(timeFrameDates);
        end
        if nnz([deficiency{:}])>0
            hereReportDeficiencyOfPlan( );
        end

        return

            function deficiency = hereCheckDeterminacyOfPlan( )
                firstColumnOfTimeFrame = runningData.TimeFrames{page}(frame, 1);
                lastColumnOfSimulation = runningData.BaseRangeColumns(end);
                [ inxOfExogenized, ...
                  inxOfEndogenized ] = getSwapsWithinTimeFrame( plan, ...
                                                                firstColumnOfTimeFrame, ...
                                                                lastColumnOfSimulation );
                numOfExogenized = nnz(inxOfExogenized);
                numOfEndogenized = nnz(inxOfEndogenized);
                deficiency = 0;
                if numOfExogenized==numOfEndogenized
                    return
                end
                if numOfExogenized>numOfEndogenized
                   if plan.AllowUnderdetermined
                       return
                   end
                   deficiency = -1;
                elseif numOfExogenized<numOfEndogenized
                    if plan.AllowOverdetermined
                        return
                    end
                    deficiency = 1;
                end
            end%


            function hereReportDeficiencyOfPlan( )
                temp = cell.empty(1, 0);
                for ii = 1 : numel(deficiency)
                    for jj = find(deficiency{ii}~=0)
                        if deficiency{ii}(jj)==-1
                            description = 'Underdetermined';
                        else
                            description = 'Overdetermined';
                        end
                        temp{end+1} = sprintf( '[DataPage %g][TimeFrame %g]: %s', ...
                                               ii, jj, description );
                    end
                end
                THIS_ERROR = { 'Model:DeficientSimulationPlan' 
                               'Simulation plan is deficient in %s' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       temp{:} );
            end%
    end%




    function herePrepareBlazer( )
        firstColumnToRun = runningData.BaseRangeColumns(1);
        lastColumnToRun = runningData.BaseRangeColumns(end);
        switch opt.Method
            case {solver.Method.STACKED, solver.Method.STATIC}
                blazer = prepareBlazer(this, opt.Method, opt);
                blazer.ColumnsToRun = firstColumnToRun : lastColumnToRun;
                run(blazer, opt);

                opt.Blocks = false;
                blazerNoBlocks = prepareBlazer(this, opt.Method, opt);
                blazerNoBlocks.ColumnsToRun = firstColumnToRun : lastColumnToRun;
                run(blazerNoBlocks, opt);
                opt.Blocks = true;

                runningData.Blazers = [blazerNoBlocks, blazer];
            otherwise
                runningData.Blazers = [ ];
        end
    end%




    function systemProperty = hereSetupSystemProperty( )
        systemProperty = SystemProperty(this);
        systemProperty.Function = @simulateTimeFrames;
        systemProperty.MaxNumOfOutputs = 1;
        systemProperty.NamedReferences = cell(1, 1);
        systemProperty.NamedReferences{1} = this.Quantity.Name;
        systemProperty.Specifics = runningData;
        if isequal(opt.SystemProperty, false)
            systemProperty.OutputNames = cell(1, 0);
        else
            systemProperty.OutputNames = opt.SystemProperty;
        end
    end%




    function progressInfo = herePrepareProgressInfo( )
        oneLiner = true;
        solver = { opt.Solver.Display };
        for ii = 1 : numel(solver)
            if ~isequal(solver{ii}, false) ...
               && ~strcmpi(solver{ii}, 'None') ...
               && ~strcmpi(solver{ii}, 'Off')
               oneLiner = false;
               break
            end
        end
        progressInfo = ProgressInfo(runningData.NumOfPages, oneLiner);
        update(progressInfo);
    end%




    function hereCheckInitialConditions( )
        % Report missing initial conditions
        firstColumnOfSimulation = runningData.BaseRangeColumns(1);
        inxOfNaNPresample = any(isnan(runningData.YXEPG(:, 1:firstColumnOfSimulation-1, :)), 3);
        checkInitialConditions(this, inxOfNaNPresample, firstColumnOfSimulation);
    end%




    function numOfDummyPeriods = hereCalculateNumOfDummyPeriods( )
        numOfDummyPeriods = opt.Window - 1;
        if ~strcmpi(opt.Method, 'FirstOrder')
            [~, maxShift] = getActualMinMaxShifts(this);
            numOfDummyPeriods = numOfDummyPeriods + maxShift;
        end
        if numOfDummyPeriods>0
            plan = extendWithDummies(plan, numOfDummyPeriods);
        end
    end%




    function hereUpdateProgressInfo(run)
        runningData.ProgressInfo.Completed = run;
        runningData.ProgressInfo.Success = nnz(runningData.Success);
        update(runningData.ProgressInfo);
    end%




    function outputData = hereCreateOutputData( )
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
        outputInfo = struct( );
        outputInfo.TimeFrames = runningData.TimeFrames;
        outputInfo.TimeFrameDates = runningData.TimeFrameDates;
        outputInfo.BaseRange = DateWrapper.fromDateCode(runningData.BaseRange);
        outputInfo.ExtendedRange = DateWrapper.fromDateCode(runningData.ExtendedRange);
        outputInfo.Success =  runningData.Success;
        outputInfo.ExitFlags = runningData.ExitFlags;
        outputInfo.DiscrepancyTables = runningData.DiscrepancyTables;
    end%




    function herePostprocessContributions( )
        inxOfLog = this.Quantity.InxOfLog;
        if opt.Method~=solver.Method.FIRST_ORDER
            % Calculate contributions of nonlinearities
            runningData.YXEPG(inxOfLog, :, end) =  runningData.YXEPG(inxOfLog, :, end) ...
                                    ./ prod(runningData.YXEPG(inxOfLog, :, 1:end-1), 3);
            runningData.YXEPG(~inxOfLog, :, end) = runningData.YXEPG(~inxOfLog, :, end) ...
                                     - sum(runningData.YXEPG(~inxOfLog, :, 1:end-1), 3);
        end
    end%
end%


%
% Local Functions
%


function flag = validateMethod(x)
    listOfMethods = {'FirstOrder', 'Selective', 'Stacked', 'NoForward'};
    if Valid.anyString(x, listOfMethods{:})
        flag = true;
    end    
    if iscell(x) && ~isempty(x) ...
       && Valid.anyString(x{1}, listOfMethods{:}) ...
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




function [timeFrames, mixinUnanticipated] = splitIntoTimeFrames(unanticipatedE, baseRangeColumns, plan, maxShift, opt)
    inxOfUnanticipatedE = unanticipatedE~=0;
    inxOfUnanticipatedAny = inxOfUnanticipatedE | plan.InxOfUnanticipatedEndogenized;
    posOfUnanticipatedAny = find(any(inxOfUnanticipatedAny, 1));
    firstColumnOfSimulation = baseRangeColumns(1);
    lastColumnOfSimulation = baseRangeColumns(end);

    % For some simulations, unanticipated shocks can be mixed in with
    % anticipated shocks within a single time frame.
    mixinUnanticipated = testMixinUnanticipated( );
    if mixinUnanticipated
       timeFrames = [firstColumnOfSimulation, lastColumnOfSimulation];
       return
    end

    if ~any(posOfUnanticipatedAny==firstColumnOfSimulation)
        posOfUnanticipatedAny = [firstColumnOfSimulation, posOfUnanticipatedAny];
    end
    lastAnticipatedExogenizedYX = plan.LastAnticipatedExogenized;
    numOfTimeFrames = numel(posOfUnanticipatedAny);
    timeFrames = nan(numOfTimeFrames, 2);
    for i = 1 : numOfTimeFrames
        startOfTimeFrame = posOfUnanticipatedAny(i);
        if i==numOfTimeFrames
            endOfTimeFrame = lastColumnOfSimulation;
        else
            endOfTimeFrame = max([posOfUnanticipatedAny(i+1)-1, lastAnticipatedExogenizedYX]);
        end
        lenOfTimeFrame = endOfTimeFrame - startOfTimeFrame + 1;
        numOfDummyPeriods = 0;
        minLenOfTimeFrame = opt.Window;
        if strcmpi(opt.Method, 'Selective')
            minLenOfTimeFrame = minLenOfTimeFrame + maxShift;
        end
        if lenOfTimeFrame<minLenOfTimeFrame
            numOfDummyPeriods = minLenOfTimeFrame - lenOfTimeFrame;
            endOfTimeFrame = endOfTimeFrame + numOfDummyPeriods;
            lenOfTimeFrame = minLenOfTimeFrame;
        end
        timeFrames(i, :) = [startOfTimeFrame, endOfTimeFrame];
    end
    mixinUnanticipated = false;

    return


        function flag = testMixinUnanticipated( )
            flag = false;
            return
            if opt.Method==solver.Method.FIRST_ORDER ...
               && plan.NumOfExogenizedPoints==0
                flag = true;
                return
            end
            if opt.Method==solver.Method.STATIC
                flag = true;
                return
            end
            flag = false;
        end%
end%
