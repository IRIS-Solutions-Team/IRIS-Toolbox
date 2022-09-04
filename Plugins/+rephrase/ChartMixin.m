classdef (Abstract) ...
    ChartMixin ...
    < matlab.mixin.Copyable


    properties (Hidden)
        Settings_HoverFormat (1, 1) string = ""
        Settings_ShowLegend (1, 1) logical = true
        Settings_Highlight = cell.empty(1, 0)
    end


    methods
        function this = set.Settings_Highlight(this, h)
            if ~iscell(h)
                hh = cell(1, numel(h));
                for i = 1 : numel(h)
                    hh{i} = h(i);
                end
            end
            for i = 1 : numel(hh)
                hh{i} = resolveHighlightDates(hh{i}, this);
            end
            this.Settings_Highlight = hh;
        end%
    end


    methods (Static)
        function date = resolveStartDate(date)
        end%

        function date = resolveEndDate(date)
        end%
    end
end

