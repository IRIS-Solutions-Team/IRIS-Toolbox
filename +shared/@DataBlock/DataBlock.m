classdef DataBlock ...
    < matlab.mixin.Copyable

    properties
        % YXEPG  NumOfQuants-by-NumOfPeriods-by-NumOfPages matrix of variables 
        YXEPG = double.empty(0)

        % Names  Names corresponding to rows in `YXEPG`
        Names = string.empty(1, 0)

        % ExtendedRange  Continuous date range corresponding to columns in `YXEPG`
        ExtendedRange = DateWrapper.empty(1, 0)

        % BaseRangeColumns  Indices of columns corresponding to base range in `ExtendedRange`
        BaseRangeColumns = double.empty(1, 0)
    end


    properties (Dependent)
        BaseRange
        InxBaseRange
        NumOfExtendedPeriods
        NumOfBasePeriods
        NumOfQuantities
        NumOfColumns
        NumOfPages
    end


    methods
        function value = get.BaseRange(this)
            extendedRange = double(this.ExtendedRange);
            extendedRange = DateWrapper.roundColon(extendedRange(1), extendedRange(end));
            value = extendedRange(this.BaseRangeColumns);
        end%


        function value = get.InxBaseRange(this)
            value = false(1, this.NumOfExtendedPeriods);
            value(this.BaseRangeColumns) = true;
        end%


        function value = get.NumOfExtendedPeriods(this)
            value = size(this.YXEPG, 2);
        end%


        function value = get.NumOfBasePeriods(this)
            value = numel(this.BaseRangeColumns);
        end%


        function value = gert.NumOfQuantities(this)
            value = size(this.YXEPG, 1);
        end%


        function value = get.NumOfColumns(this)
            value = size(this.YXEPG, 2);
        end%


        function value = get.NumOfPages(this)
            value = size(this.YXEPG, 3);
        end%
    end
end
        
