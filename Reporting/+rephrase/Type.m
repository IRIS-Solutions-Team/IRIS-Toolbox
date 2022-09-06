classdef Type
    enumeration
        VOID
        REPORT

        SECTION
        GRID
        TABLE
        CHART
        SERIESCHART
        CURVECHART
        PAGER

        SERIES
        DIFFSERIES
        HEADING
        PAGEBREAK
        TEXT
        MATRIX
        CURVE
        MARKER

        HIGHLIGHT
        BANDS
    end


    methods (Static)
        function flag = isChart(this)
            IS_CHART = string([
                rephrase.Type.CHART
                rephrase.Type.SERIESCHART
                rephrase.Type.CURVECHART
            ]);
            if isa(this, 'rephrase.Type')
                this = string(this);
            end
            flag = ismember(this, IS_CHART);
        end%
    end%
end



