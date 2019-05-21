classdef InputOutputData < handle
    properties
        YXEPG
        Blazers
        BaseRange
        ExtendedRange
        BaseRangeColumns
        MaxShift
        TimeTrend
        NumOfDummyPeriods
        InxOfInitInPresample
        MixinUnanticipated
        TimeFrames
        TimeFrameDates
        Success
        ExitFlags
        DiscrepancyTables
    end


    properties (Dependent)
        NumOfPages
    end


    methods
        function n = get.NumOfPages(this)
            n = size(this.YXEPG, 3);
        end%
    end
end

