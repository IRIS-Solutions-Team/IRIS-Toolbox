function outputData = simulate(this, inputData, baseRange, varargin)

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
    parser.addParameter('Method', 'FirstOrder', @(x) validateString(x, {'FirstOrder', 'Selective', 'Stacked'})); 
    parser.addParameter('OutputData', 'Databank', @(x) validateString(x, {'Databank', 'simulate.Data'}));
    parser.addParameter('Plan', true, @(x) isequal(x, true) || isequal(x, false) || isa(x, 'Plan'));
    parser.addParameter('Solver', @auto, @validateSolver);
    parser.addParameter('Window', @auto, @(x) isequal(x, @auto) || isequal(x, @max) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=1));
end
parser.parse(this, inputData, baseRange, varargin{:});
opt = parser.Options;

opt.Window = parseWindow(opt.Window, opt.Method, baseRange);
opt.Solver = parseSolver(opt.Solver, opt.Method);

%--------------------------------------------------------------------------

plan = opt.Plan;
if ~isa(plan, 'Plan')
    plan = Plan(this, baseRange, 'Anticipate=', plan);
else
    checkCompatibilityOfPlan(this, baseRange, plan);
end

outputData = simulateFirstOrder(this, inputData, baseRange, plan, opt);

if isstruct(outputData)
    outputData = appendData(this, inputData, outputData, baseRange, opt);
end

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


function window = parseWindow(window, method, baseRange)
    if isequal(window, @auto)
        if strcmpi(method, 'FirstOrder')
            window = 1;
        elseif strcmpi(method, 'Selective')
            window = @max;
        end
    end
    baseRange = double(baseRange);
    lenOfBaseRange = round(baseRange(end) - baseRange(1) + 1);
    if isequal(window, @max)
        window = lenOfBaseRange;
    elseif isnumeric(window) && window>lenOfBaseRange
        THIS_ERROR = { 'Model:WindowCannotExceedRangeLength'
                       'Simulation window cannot exceed number of simulation periods' };
        throw( exception.Base(THIS_ERROR, 'error') );
    end
end%


function solver = parseSolver(solver, method)
    if strcmpi(method, 'FirstOrder')
        solver = [ ];
        return
    end
    if strcmpi(method, 'Selective')
        prepareGradient = false;
        displayMode = 'Verbose';
        solver = solver.Options.parserOptions(solver, method, prepareGradient, displayMode);
        return
    end
end%

