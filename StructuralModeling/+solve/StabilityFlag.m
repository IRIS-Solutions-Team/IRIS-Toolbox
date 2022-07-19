classdef StabilityFlag < double
    enumeration
        UNIQUE_STABLE (1)
        NO_STABLE (0)
        MULTIPLE_STABLE (Inf)
        NAN_SOLUTION (-1)
        NAN_EIGEN (-2)
        NAN_SYSTEM (-3)
        INVALID_STEADY (-4)
        COMPLEX_SYSTEM (-5)
        UNKNOWN (-6)
    end

    methods
        function status = hasSucceeded(this)
            status = this==solve.StabilityFlag.UNIQUE_STABLE;
        end%
    end
end

