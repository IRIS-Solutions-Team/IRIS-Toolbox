% getActualMinMaxShifts  Actual minimum and maximum shifts across dynamic and steady equations
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [minSh, maxSh] = getActualMinMaxShifts(this)

[dynamicMinSh, dynamicMaxSh] = getMinMaxShifts(this.Incidence.Dynamic);
[steadyMinSh, steadyMaxSh] = getMinMaxShifts(this.Incidence.Steady);
minSh = min([-1, dynamicMinSh, steadyMinSh]);
maxSh = max([ 0, dynamicMaxSh, steadyMaxSh]);

end%

