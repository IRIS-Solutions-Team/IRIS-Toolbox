classdef Curve ...
    < rephrase.Terminal ...
    & rephrase.ColorMixin ...
    & rephrase.PlotMixin

    properties
        Type = string(rephrase.Type.CURVE)
    end


    properties (Hidden)
        Input
    end


    methods
        function this = Curve(title, input, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Input = input;
        end%


        function finalize(this, varargin)
            finalize@rephrase.Terminal(this);
            [this.Content, text] = finalizeCurveData(this, this.Input);
            if isempty(this.Settings.Text)
                this.Settings.Text = text;
            end
        end%


        function [content, text] = finalizeCurveData(this, input)
            parent = this.Parent;
            text = string.empty(1, 0);
            if isa(input, 'Termer')
                minTick = min(parent.Settings_Ticks);
                maxTick = max(parent.Settings_Ticks);
                t = clip(input, minTick, maxTick);
                ticks = t.Terms(:, 1);
                values = t.Values;
                text = reshape(t.RowLabels, 1, []);
            elseif isa(input, 'struct') && isfield(input, 'Terms') && isfield(input, 'Values')
                ticks = double(input.Terms(:, 1));
                values = double(input.Values(:, :));
                text = repmat("", 1, numel(values));
            end

            spreads = [];
            if size(values, 2)>=2
                spreads = values(:, 2) - values(:, 1);
                values = values(:, 1);
            end

            content = struct('Ticks', [], 'Values', [], 'Spreads', []);
            content.Ticks = ticks;
            content.Values = values;
            content.Spreads = spreads;
            for n = ["Values", "Ticks", "Spreads"]
                content.(n) = reshape(content.(n), 1, []);
                if isscalar(content.(n)) && ~iscell(content.(n))
                    content.(n) = {content.(n)};
                end
            end
        end%
    end
end 

