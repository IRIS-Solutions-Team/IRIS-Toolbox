classdef DataBlock ...
    < matlab.mixin.Copyable

    properties
        % YXEPG  NumQuantities-by-NumExtdPeriods-by-NumPages matrix of variables 
        YXEPG (:, :, :) double = double.empty(0, 0, 0)

        % CleanYXEPG  Clean copy of input data
        CleanYXEPG (:, :, :) double = double.empty(0, 0, 0)

        % Names  Names corresponding to rows in `YXEPG`
        Names (1, :) string = string.empty(1, 0)

        % ExtendedRange  Continuous date range corresponding to columns in `YXEPG`
        ExtendedRange (1, :) double = double.empty(1, 0)

        % BaseRangeColumns  Indices of columns corresponding to base range in `ExtendedRange`
        BaseRangeColumns (1, :) double = double.empty(1, 0)
    end


    properties (Dependent)
        BaseRange
        InxBaseRange
        NumExtdPeriods
        NumBasePeriods
        NumQuantities
        NumColumns
        NumPages
    end


    methods
        function value = get.BaseRange(this)
            extendedRange = double(this.ExtendedRange);
            extendedRange = dater.colon(extendedRange(1), extendedRange(end));
            value = extendedRange(this.BaseRangeColumns);
        end%


        function value = get.InxBaseRange(this)
            value = false(1, this.NumExtdPeriods);
            value(this.BaseRangeColumns) = true;
        end%


        function value = get.NumExtdPeriods(this)
            value = size(this.YXEPG, 2);
        end%


        function value = get.NumBasePeriods(this)
            value = numel(this.BaseRangeColumns);
        end%


        function value = gert.NumQuantities(this)
            value = size(this.YXEPG, 1);
        end%


        function value = get.NumColumns(this)
            value = size(this.YXEPG, 2);
        end%


        function value = get.NumPages(this)
            value = size(this.YXEPG, 3);
        end%
    end
end
        
