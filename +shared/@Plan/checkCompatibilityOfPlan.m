function checkCompatibilityOfPlan(this, baseRange, plan)
% checkCompatibilityOfPlan  Check compatibility of plan, simulation range and simulated object
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

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
if ~DateWrapper.roundEqual(baseRange(1), plan.BaseStart) ...
    || ~DateWrapper.roundEqual(baseRange(end), plan.BaseEnd)
    thisError = [ "Model:PlanRangeNotConsistent"
                  "Plan is not compatible with the simulation range" ];
    throw(exception.Base(thisError, 'error'));
end

%
% Check the names of endogenous and exogenous quantities
%
namesEndogenous = getEndogenousForPlan(this);
namesExogenous = getExogenousForPlan(this);
if ~isequal(string(plan.NamesOfEndogenous), string(namesEndogenous)) ...
        || ~isequal(string(plan.NamesOfExogenous), string(namesExogenous))
    thisError = [ "Model:PlanQuantitiesNotConsistent"
                  "Plan is not compatible with the %1 object to be simulated" ];
    throw(exception.Base(thisError, 'error'), class(this));
end
    
end%

