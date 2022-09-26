
classdef (Abstract) PlotMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_ShowLegend (1, 1) logical = true
        Settings_LineWidth (1, 1) double {mustBeNonnegative} = 2
        Settings_Type (1, 1) string = "scatter"
        Settings_Markers (1, 1) = struct() 
        Settings_StackGroup (1, 1) string = ""
        Settings_Fill (1, 1) string = "none"
        Settings_Text (1, :) string = string.empty(1, 0)
    end


    methods
        function this = set.Settings_Markers(this, x)
            if isstruct(x)
                this.Settings_Markers = rephrase.lowerFields(x);
            else
                this.Settings_Markers = NaN;
            end
        end%
    end
end
