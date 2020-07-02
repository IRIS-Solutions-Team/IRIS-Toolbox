function [minSh, maxSh] = getActualMinMaxShifts(this)
% getActualMinMaxShifts  Actual minimum and maximum shifts across dynamic and steady equations
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

minSh = min([-1, this.Incidence.Dynamic.MinShift, this.Incidence.Steady.MinShift]);
maxSh = max([ 0, this.Incidence.Dynamic.MaxShift, this.Incidence.Steady.MaxShift]);

end%

