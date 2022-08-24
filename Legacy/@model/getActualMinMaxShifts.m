function [minSh1, maxSh0, minSh0] = getActualMinMaxShifts(this)

[dynamicMinSh, dynamicMaxSh] = getMinMaxShifts(this.Incidence.Dynamic);
[steadyMinSh, steadyMaxSh] = getMinMaxShifts(this.Incidence.Steady);
minSh0 = min([0, dynamicMinSh, steadyMinSh]);
minSh1 = min([-1, dynamicMinSh, steadyMinSh]);
maxSh0 = max([0, dynamicMaxSh, steadyMaxSh]);

end%

