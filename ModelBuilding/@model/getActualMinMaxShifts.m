function [minSh, maxSh] = getActualMinMaxShifts(this)
% getActualMinMaxShifts  Actual minimum and maximum shifts across dynamic and steady equations
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

minSh = min([-1, this.Incidence.Dynamic.MinShift, this.Incidence.Steady.MinShift]);
maxSh = max([ 0, this.Incidence.Dynamic.MaxShift, this.Incidence.Steady.MaxShift]);

end
