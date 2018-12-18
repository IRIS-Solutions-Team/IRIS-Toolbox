function outputData = simulate(this, inputData, baseRange, varargin)

persistent parser
if isempty(parser)
    validateString = @(x, list) (ischar(x) || isa(x, 'string')) && any(strcmpi(x, list));
    parser = extend.InputParser('model.simulate');
    parser.addRequired('SolvedModel', @(x) isa(x, 'Model') && all(issolved(x)));
    parser.addRequired('InputData', @(x) isstruct(x) || isa(x, 'simulate.Data'));
    parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
    parser.addParameter({'Deviation', 'Deviations'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Method', 'FirstOrder', @(x) validateString(x, {'FirstOrder', 'Selective', 'Stacked'})); 
    parser.addParameter('OutputData', 'Databank', @(x) validateString(x, {'Databank', 'simulate.Data'}));
    parser.addParameter('Plan', true, @(x) isequal(x, true) || isequal(x, false) || isa(x, 'Plan'));
end
parser.parse(this, inputData, baseRange, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

plan = opt.Plan;
if ~isa(plan, 'Plan')
    plan = Plan(this, baseRange, 'Anticipate=', plan);
else
    checkCompatibilityOfPlan(this, baseRange, plan);
end

outputData = simulateFirstOrder(this, inputData, baseRange, plan, opt);

end%
