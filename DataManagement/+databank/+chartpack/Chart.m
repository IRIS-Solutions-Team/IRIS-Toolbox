classdef (CaseInsensitiveProperties=true) Chart < handle

    properties
        ParentChartpack = []

        InputString (1, 1) = ""
        Caption (1, 1) string = ""
        Expression (1, 1) string = ""
        Data = []

        ApplyTransform = true
        Transform = []

        PlotSettings = cell.empty(1, 0)
    end


    methods
        function this = Chart(varargin)
            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
        end%


        function evaluate(this, inputDb)
            parent = this.ParentChartpack;
            if isempty(this.Data) && ~ismissing(this.Expression) && strlength(this.Expression)>0
                this.Data = databank.eval(inputDb, this.Expression);
                if this.ApplyTransform && ~isempty(parent.Transform)
                    this.Data = parent.Transform(this.Data);
                    this.Transform = parent.Transform;
                end
            end
        end%


        function caption = resolveCaption(this)
            parent = this.ParentChartpack;
            if ~ismissing(this.Caption) && strlength(this.Caption)>0
                caption = this.Caption;
            elseif ~ismissing(this.Expression) && strlength(this.Expression)>0
                caption = this.Expression;
                if ~isempty(this.Transform)
                    caption(1) = caption(1) + "; " + string(func2str(this.Transform));
                end
            else
                caption = string(missing);
            end
            if ~ismissing(parent.NewLine) && strlength(parent.NewLine)>0
                caption = strip(split(caption, parent.NewLine));
            end
        end%
    end


    methods (Static)
        function this = fromString(inputString, varargin)
            %(
            arguments
                inputString (1, :) string
            end
            arguments (Repeating)
                varargin
            end

            this = databank.chartpack.Chart.empty(1, 0);
            inxValid = logical.empty(1, 0);
            for n = inputString
                temp = databank.chartpack.Chart(varargin{:});
                temp.InputString = strip(n);
                [temp.Caption, temp.Expression, temp.ApplyTransform] ...
                    = databank.chartpack.Chart.parseInputString(temp.InputString); 
                this(end+1) = temp;
            end
            %)
        end%


        function [caption, expression, applyTransform] = parseInputString(inputString)
            %(
            arguments
                inputString (1, 1) string
            end
            temp = strip(split(inputString, ":"));
            if numel(temp)==1
                caption = "";
                expression = temp;
            else
                caption = temp(1);
                expression = join(temp(2:end), ":");
            end
            applyTransform = true;
            if startsWith(expression, "^")
                expression = extractAfter(expression, 1);
                applyTransform = false;
            end
            %)
        end%
    end
end

