function checkCompatibilityOfPlan(this, baseRange, plan)
% checkCompatibilityOfPlan  Check compatibility of plan, simulation range and simulation plan
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

if isequal(plan, true) || isequal(plan, false)
    return
end

% Check simulation range
baseRange = double(baseRange);
if round(100*baseRange(1))~=round(100*plan.BaseStart) ...
    || round(100*baseRange(end))~=round(100*plan.BaseEnd)
    THIS_ERROR = { 'Model:PlanRangeNotConsistent'
                   'Plan is not compatible with simulation range' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

% Check Quantity component: Name, InxOfLog
inxOfYX = getIndexByType(this.Quantity, TYPE(1), TYPE(2));
inxOfE = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
if plan.NumOfEndogenous~=nnz(inxOfYX) || plan.NumOfExogenous~=nnz(inxOfE)
    THIS_ERROR = { 'Model:PlanQuantitiesNotConsistent'
                   'Plan is not compatible with the model to be simulated' };
    throw( exception.Base(THIS_ERROR, 'error') );
end
    
end%

