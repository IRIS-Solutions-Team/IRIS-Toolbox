% getExtendedRange  Extend base range for dynamic simulations to include presample and postsample

function ...
    [startExtRange, endExtRange, minShift, maxShift, inxBaseRange] ...
    = getExtendedRange(this, baseRange)

    baseRange = double(baseRange);
    startBaseRange = baseRange(1);
    endBaseRange = baseRange(end);

    % Minimum and maximum *actual* shifts
    [minShift, maxShift] = getActualMinMaxShifts(this);

    startExtRange = startBaseRange;
    if minShift<0
        startExtRange = dater.plus(startExtRange, minShift);
    end

    endExtRange = endBaseRange;
    if maxShift>0
        endExtRange = dater.plus(endExtRange, maxShift);
    end

    if nargout<=4
        return
    end

    numExtPeriods = dater.rangeLength(startExtRange, endExtRange);
    inxBaseRange = true(1, numExtPeriods);
    inxBaseRange(1:abs(minShift)) = false;
    inxBaseRange(end-maxShift+1:end) = false;

end%

