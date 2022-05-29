% checkPlanConsistency  Check consistency of plan, simulation range and simulated object
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function plan = checkPlanConsistency(this, baseRange, plan)


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
        "Plan"
        "The Plan range is not consistent with the simulation range."
    ]);
end


%
% Number of variants
%
numVariantsModel = countVariants(this);
numVariantsPlan = countVariants(plan);
if (numVariantsModel~=1 || numVariantsPlan~=1) && numVariantsModel~=numVariantsPlan
    exception.error([ 
        "Plan"
        "The number of variants in the Plan object (%g) is not consistent "
        "with the number of variants in the simulated object (%g)."
    ], numVariantsPlan, numVariantsModel);
end


%
% Check the names of endogenous and exogenous quantities
%
namesEndogenous = getEndogenousForPlan(this);
namesExogenous = getExogenousForPlan(this);
if ~isequal(string(plan.NamesOfEndogenous), string(namesEndogenous)) ...
        || ~isequal(string(plan.NamesOfExogenous), string(namesExogenous))
    exception.error([
        "Plan"
        "The Plan object is not consistent with the simulated object."
    ], string(class(this)));
end

end%

