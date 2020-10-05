% checkCompatibilityOfPlan  Check compatibility of plan, simulation range and simulated object
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function plan = checkCompatibilityOfPlan(this, baseRange, plan)

%
% Option Plan= can be empty, `true`, or `false`
%
if ~isa(plan, 'Plan')
    return
end

%
% Check the simulation range
%
baseRange = double(baseRange);
if ~dater.eq(baseRange(1), plan.BaseStart) || ~dater.eq(baseRange(end), plan.BaseEnd)
    exception.error([ 
        "Model:PlanRangeNotConsistent"
        "Plan is not compatible with the simulation range"
    ]);
end

%
% Check the names of endogenous and exogenous quantities
%
namesEndogenous = getEndogenousForPlan(this);
namesExogenous = getExogenousForPlan(this);
if ~isequal(string(plan.NamesOfEndogenous), string(namesEndogenous)) ...
        || ~isequal(string(plan.NamesOfExogenous), string(namesExogenous))
    exception.error([
        "Model:PlanQuantitiesNotConsistent"
        "Plan is not compatible with the %1 object to be simulated"
    ], string(class(this)));
end
    
end%

