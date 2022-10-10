classdef (Abstract) ...
    ChartMixin ...
    < matlab.mixin.Copyable


    properties (Hidden)
        Settings_HoverFormat (1, 1) string = ""
        Settings_ShowLegend (1, 1) logical = true
        Settings_Highlight = cell.empty(1, 0)
        Settings_Layout = struct()
    end


    methods
        function this = set.Settings_Highlight(this, h)
            if ~iscell(h)
                h__ = h;
                h = cell(1, numel(h__));
                for i = 1 : numel(h__)
                    h{i} = h__(i);
                end
            end
            for i = 1 : numel(h)
                h{i} = resolveHighlightDates(h{i}, this);
            end
            this.Settings_Highlight = h;
        end%
    end


    methods (Static)
        function date = resolveStartDate(date)
        end%

        function date = resolveEndDate(date)
        end%
    end
end

