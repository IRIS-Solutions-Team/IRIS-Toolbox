classdef Curve ...
    < rephrase.Terminal ...
    & rephrase.ColorMixin ...
    & rephrase.PlotMixin

    properties % (Constant)
        Type = string(rephrase.Type.CURVE)
    end


    methods
        function this = Curve(title, input, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = input;
        end%


        function finalize(this, varargin)
            finalize@rephrase.Terminal(this);
            finalizeCurveData(this);
        end%


        function finalizeCurveData(this)
            if isa(this.Content, 'Termer')
                minTick = min(this.Parent.Settings_Ticks);
                maxTick = max(this.Parent.Settings_Ticks);
                t = clip(this.Content, minTick, maxTick);
                this.Content = struct();
                this.Content.Ticks = reshape(t.Terms(:, 1), 1, []);
                this.Content.Values = reshape(t.Values(:, 1), 1, []);
                this.Content.Spreads = [];
                if size(t.Values, 2)==2
                    this.Content.Spreads = reshape(t.Values(:, 2) - t.Values(:, 1), 1, []);
                end
                this.Settings.Text = reshape(t.RowLabels, 1, []);
            end
        end%
    end
end 

