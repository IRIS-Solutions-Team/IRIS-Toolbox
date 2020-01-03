function ...
    [startExtRange, endExtRange, minShift, maxShift, inxBaseRange] ...
    = getExtendedRange(this, baseRange)
% getExtendedRange  Extend base range for dynamic simulations to include presample and postsample
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

baseRange = double(baseRange);
startBaseRange = baseRange(1);
endBaseRange = baseRange(end);

% Minimum and maximum *actual* shifts
[minShift, maxShift] = getActualMinMaxShifts(this);

startExtRange = startBaseRange;
if minShift<0
    startExtRange = startExtRange + minShift;
end

endExtRange = endBaseRange;
if maxShift>0
    endExtRange = endExtRange + maxShift;
end

if nargout<=4
    return
end

numExtPeriods = round(endExtRange - startExtRange + 1);
inxBaseRange = true(1, numExtPeriods);
inxBaseRange(1:abs(minShift)) = false;
inxBaseRange(end-maxShift+1:end) = false;

end%

