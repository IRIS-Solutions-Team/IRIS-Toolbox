function [startOfExtRange, endOfExtRange, minShift, maxShift] = getExtendedRange(this, startOfBaseRange, endOfBaseRange)
% getExtendedRange  Extend base range for dynamic simulations to include presample and postsample
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

% Minimum and maximum *actual* shifts
[minShift, maxShift] = getActualMinMaxShifts(this);

startOfExtRange = startOfBaseRange;
if minShift<0
    startOfExtRange = addTo(startOfExtRange, minShift);
end

endOfExtRange = endOfBaseRange;
if maxShift>0
    endOfExtRange = addTo(endOfExtRange, maxShift);
end

end
