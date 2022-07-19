classdef Curve ...
    < rephrase.Terminal ...
    & rephrase.ColorMixin

    properties % (Constant)
        Type = rephrase.Type.CURVE
    end


    methods
        function this = Curve(title, input, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = input;
        end%


        function finalize(this)
            finalize@rephrase.Terminal(this);
            this.Content = finalizeCurveData(this, this.Content);
        end%


        function output = finalizeCurveData(this, input);
            if isstring(input) || ischar(input)
                output = string(input);
                this.DataRequests = union(this.DataRequests, output, 'stable');
                return
            end
            minTick = min(this.Parent.Settings_Ticks);
            maxTick = max(this.Parent.Settings_Ticks);
            inxTicks = input.Ticks>=minTick & input.Ticks<=maxTick;
            output = struct();
            output.Ticks = reshape(input.Ticks(inxTicks), 1, []);
            output.Values = reshape(input.Values(inxTicks), 1, []);
        end%
    end


    methods (Static)
        function these = fromMultivariate(titles, inputs, varargin)
            titles = textual.stringify(titles);
            isInputCell = iscell(inputs);
            numTitles = numel(titles);
            numCurves = numel(inputs);
            these = rephrase.Curve.empty(1, 0);
            if numTitles==1 && numCurves>1
                titles = repmat(titles, 1, numCurves);
            end
            for i = 1 : numCurves
                if isInputCell
                    this = inputs{i};
                else
                    this = inputs(i);
                end
                these(end+1) = rephrase.Curve(titles(i), this, varargin{:});
            end
        end%
    end
end 
