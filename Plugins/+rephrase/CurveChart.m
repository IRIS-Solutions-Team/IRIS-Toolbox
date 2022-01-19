classdef CurveChart ...
    < rephrase.Element ...
    & rephrase.Container

    properties % (Constant)
        Type = rephrase.Type.CHART
    end


    properties (Constant, Hidden)
        PossibleChildren = [ 
            rephrase.Type.CURVE, ...
            rephrase.Type.MARKER
        ]
    end


    methods
        function this = CurveChart(title, ticks, tickLabels, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings.ChartType = "Curve";
            this.Settings.Ticks = ticks;
            this.Settings.TickLabels = tickLabels;
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

