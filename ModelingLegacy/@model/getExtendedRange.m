function [ startOfExtRange, ...
           endOfExtRange, ...
           minShift, maxShift] = getExtendedRange(this, baseRange);
% getExtendedRange  Extend base range for dynamic simulations to include presample and postsample
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

baseRange = double(baseRange);
startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);

% Minimum and maximum *actual* shifts
[minShift, maxShift] = getActualMinMaxShifts(this);

startOfExtRange = startOfBaseRange;
if minShift<0
    startOfExtRange = startOfExtRange + minShift;
end

endOfExtRange = endOfBaseRange;
if maxShift>0
    endOfExtRange = endOfExtRange + maxShift;
end

end%

