classdef (Abstract) ...
    ChartMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_HoverFormat (1, 1) string = ""
        Settings_ShowLegend (1, 1) logical = true
    end
end

