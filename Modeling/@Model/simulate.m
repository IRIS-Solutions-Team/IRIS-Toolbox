function outputDatabank = simulate(this, inputDatabank, baseRange, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.simulate');
    parser.addRequired('SolvedModel', @(x) isa(x, 'Model') && all(issolved(x)));
    parser.addRequired('InputDatabank', @isstruct);
    parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
    parser.addParameter({'Deviation', 'Deviations'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Method', 'FirstOrder', @(x) (ischar(x) || isa(x, 'string')) && any(strcmpi(x, {'FirstOrder', 'Selective', 'Stacked'})));
    parser.addParameter('Plan', true, @(x) isequal(x, true) || isequal(x, false) || isa(x, 'Plan'));
end
parser.parse(this, inputDatabank, baseRange, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

plan = opt.Plan;
if ~isa(plan, 'Plan')
    plan = Plan(this, baseRange, 'Anticipate=', plan);
else
    checkCompatibilityOfPlan(this, baseRange, plan);
end

outputDatabank = simulateFirstOrder(this, inputDatabank, baseRange, plan, opt);

end%
