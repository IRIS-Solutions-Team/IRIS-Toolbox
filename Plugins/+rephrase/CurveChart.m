classdef CurveChart ...
    < rephrase.Container ...
    & rephrase.ChartMixin

    properties
        Type = rephrase.Type.CURVECHART
    end


    properties (Hidden)
        Settings_Ticks
        Settings_TickLabels
    end


    properties (Constant, Hidden)
        PossibleChildren = [ 
            rephrase.Type.CURVE
            rephrase.Type.MARKER
        ]
    end


    methods
        function this = CurveChart(title, ticks, tickLabels, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings_Ticks = ticks;
            this.Settings_TickLabels = tickLabels;
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

