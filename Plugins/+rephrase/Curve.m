classdef Curve ...
    < rephrase.Element ...
    & rephrase.Terminus ...
    & rephrase.Data

    properties % (Constant)
        Type = rephrase.Type.CURVE
    end


    methods
        function this = Curve(title, input, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = input;
        end%


        function build(this, varargin)
            this.Content = buildCurveData(this, this.Content);
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
