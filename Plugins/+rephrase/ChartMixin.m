classdef (Abstract) ...
    ChartMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_ShowTitle (1, 1) logical = true
        Settings_HoverFormat (1, 1) string = ""
    end
end

