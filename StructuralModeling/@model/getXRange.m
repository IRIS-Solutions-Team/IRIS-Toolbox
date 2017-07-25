function [xRange, minSh, maxSh] = getXRange(this, range, isPre, isPost)
% getXRange  Extend range for dynamic simulations to include presample and postsample.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try, isPre; catch, isPre = true; end %#ok<VUNUS,NOCOM>
try, isPost; catch, isPost = false; end %#ok<VUNUS,NOCOM>

%--------------------------------------------------------------------------

[minSh, maxSh] = getMaxShift(this.Incidence.Dynamic);
minSh = min(minSh, -1);

if ~isPre
    minSh = 0;
end

if ~isPost
   maxSh = 0;
end

xRange = range(1)+minSh : range(end)+maxSh;

end
