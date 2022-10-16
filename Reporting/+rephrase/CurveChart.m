
classdef CurveChart ...
    < rephrase.Container ...
    & rephrase.ChartMixin

    properties
        Type = string(rephrase.Type.CURVECHART)
    end


    properties (Hidden)
        Settings_DateFormat (1, 1) string = ""
        Settings_Ticks
        Settings_TickLabels = @(x) sprintf("%g", x)
    end


    properties (Constant, Hidden)
        PossibleChildren = [ 
            string(rephrase.Type.CURVE)
        ]
    end


    methods
        function this = CurveChart(title, ticks, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings_Ticks = ticks;
            if isa(this.Settings_TickLabels, 'function_handle')
                func = this.Settings_TickLabels;
                this.Settings_TickLabels = string(arrayfun(func, this.Settings_Ticks));
            end
        end%
    end


    methods (Static)
        function this = fromCurve(chartInputs, curveInputs)
            this = rephrase.CurveChart(chartInputs{:});
            curves = rephrase.Curve.fromMultivariate(curveInputs{:});
            add(this, curves);
        end%
    end
end

