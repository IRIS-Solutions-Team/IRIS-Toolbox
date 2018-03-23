function [extendedRange, minSh, maxSh] = getExtendedRange(this, baseRange)
% getExtendedRange  Extend base range for dynamic simulations to include presample and postsample.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Minimum and maximum _actual_ shifts.
[minSh, maxSh] = getActualMinMaxShifts(this);
extendedRange = baseRange(1)+minSh : baseRange(end)+maxSh;

end
