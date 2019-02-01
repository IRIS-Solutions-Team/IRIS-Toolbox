function [outputData, outputInfo] = simulate(this, inputData, baseRange, varargin)

persistent parser
if isempty(parser)
    validateString = @(x, list) (ischar(x) || isa(x, 'string')) && any(strcmpi(x, list));
    parser = extend.InputParser('model.simulate');
    parser.addRequired('SolvedModel', @(x) isa(x, 'Model') && all(issolved(x)));
    parser.addRequired('InputData', @(x) isstruct(x) || isa(x, 'simulate.Data'));
    parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);

    parser.addDeviationOptions(false);
    parser.addParameter('AppendPostsample', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('AppendPresample', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Contributions', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Method', 'FirstOrder', @(x) validateString(x, {'FirstOrder', 'Selective', 'Stacked'})); 
    parser.addParameter('IgnoreShocks', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('OutputData', 'Databank', @(x) validateString(x, {'Databank', 'simulate.Data'}));
    parser.addParameter('Anticipate', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Plan', true, @(x) isequal(x, true) || isequal(x, false) || isa(x, 'Plan'));
    parser.addParameter('Solver', @auto, @validateSolver);
    parser.addParameter('Window', @auto, @(x) isequal(x, @auto) || isequal(x, @max) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=1));
end
parser.parse(this, inputData, baseRange, varargin{:});
opt = parser.Options;
opt.EvalTrends = opt.DTrends;
usingDefaults = parser.UsingDefaultsInStruct;

opt.Window = parseWindowOption(opt.Window, opt.Method, baseRange);
opt.Solver = parseSolverOption(opt.Solver, opt.Method);

%--------------------------------------------------------------------------


% Check the input databank; treat all names as optional, and check for
% missing initial conditions later
requiredNames = cell.empty(1, 0);
optionalNames = this.Quantity.Name;
databankInfo = checkInputDatabank(this, inputData, baseRange, requiredNames, optionalNames);

hereResolveOptionConflicts( );

[outputData, outputInfo] = simulateFirstOrder(this, inputData, baseRange, opt.Plan, databankInfo, opt);

if isstruct(outputData)
    outputData = appendData(this, inputData, outputData, baseRange, opt);
end

if nargout>=2
    outputInfo = postprocessOutputInfo(this, outputInfo);
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
end%


%
% Local Functions
%


function flag = validateMethod(x)
    validateString = @(x, list) (ischar(x) || isa(x, 'string')) && any(strcmpi(x, list));
    listOfMethods = {'FirstOrder', 'Selective'};
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
    flag = isequal(x, @auto) || validateSolverName(x) ...
           || (iscell(x) && validateSolverName(x{1}) && iscellstr(x(2:2:end)));
end%


function flag = validateSolverName(x)
    flag = (ischar(x) && any(strcmpi(x, {'IRIS-qad', 'IRIS-qnsd', 'IRIS-newton', 'qad', 'IRIS', 'lsqnonlin', 'fsolve'}))) ...
           || isequal(x, @fsolve) || isequal(x, @lsqnonlin) || isequal(x, @qad);
end%


function windowOption = parseWindowOption(windowOption, methodOption, baseRange)
    if isequal(windowOption, @auto)
        if strcmpi(methodOption, 'FirstOrder')
            windowOption = 1;
        elseif strcmpi(methodOption, 'Selective')
            windowOption = @max;
        end
    end
    baseRange = double(baseRange);
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
    if strcmpi(methodOption, 'FirstOrder')
        solverOption = [ ];
        return
    end
    if strcmpi(methodOption, 'Selective')
        prepareGradient = false;
        displayMode = 'Verbose';
        solverOption = solver.Options.parseOptions(solverOption, methodOption, prepareGradient, displayMode);
        return
    end
end%


function outputInfo = postprocessOutputInfo(this, outputInfo)
    numOfRuns = numel(outputInfo.TimeFrames);
    for run = 1 : numOfRuns
        timeFrames = outputInfo.TimeFrames{run};
        numOfTimeFrames = size(timeFrames);
        extendedRange = double(outputInfo.ExtendedRange);
        startOfExtendedRange = extendedRange(1);
        endOfExtendedRange = extendedRange(end);
        for frame = 1 : numOfTimeFrames
            startOfTimeFrame = startOfExtendedRange + timeFrames(frame, 1) - 1;
            endOfTimeFrame = startOfExtendedRange + timeFrames(frame, 2) - 1;
            timeFrames(frame, :) = [startOfTimeFrame, endOfTimeFrame];
        end
        outputInfo.TimeFrames{run} = DateWrapper.fromDateCode(timeFrames);
    end
    outputInfo.BaseRange = DateWrapper.fromDateCode(outputInfo.BaseRange);
    outputInfo.ExtendedRange = DateWrapper.fromDateCode(outputInfo.ExtendedRange);
end%

