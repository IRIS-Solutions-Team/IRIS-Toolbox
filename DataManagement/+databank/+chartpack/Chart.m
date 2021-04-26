classdef (CaseInsensitiveProperties=true) Chart < handle

    properties
        ParentChartpack = []

        InputString (1, 1) = ""
        Caption (1, 1) string = ""
        Expression (1, 1) string = ""
        Data = []

        Expansion = @parent
        ApplyTransform = true
        Transform = @parent

        PlotSettings = cell.empty(1, 0)
    end


    properties (Constant)
        SEPARATE_CAPTION = ":"
        EXCLUDE_FROM_TRANSFORM = "^"
        EXPANSION_MARK = "?"
    end


    methods
        function this = Chart(varargin)
            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
        end%


        function expansion = getExpansion(this)
            expansion = this.Expansion;
            if isequal(expansion, @parent)
                expansion = this.ParentChartpack.Expansion;
            end
        end%


        function transform = getTransform(this)
            transform = this.Transform;
            if isequal(transform, @parent)
                transform = this.ParentChartpack.Transform;
            end
        end%


        function evaluate(this, inputDb)
            expression = this.Expression;
            if isempty(this.Data) && ~ismissing(expression) && strlength(expression)>0
                expression = expand(this, expression);
                this.Data = databank.eval(inputDb, expression);
                if this.ApplyTransform
                    transform = getTransform(this);
                    if ~isempty(transform)
                        this.Data = transform(this.Data);
                    end
                end
            end
        end%


        function expression = expand(this, expression)
            expansion = getExpansion(this);
            if isempty(expansion)
                return
            end
            for i = 1 : 2 : numel(expansion)
                if contains(expression, expansion{i})
                    newExpression = string.empty(1, 0);
                    for n = reshape(string(expansion{i+1}), 1, [])
                        newExpression(end+1) = replace(expression, expansion{i}, n);
                    end
                    expression = "[" + join(newExpression, ", ") + "]";
                    break
                end
            end
        end%


        function caption = resolveCaption(this)
            parent = this.ParentChartpack;
            if ~ismissing(this.Caption) && strlength(this.Caption)>0
                caption = this.Caption;
                if parent.ShowFormulas
                    caption = [caption; hereCreateFormula()];
                end
            elseif parent.CaptionFromComment && isa(this.Data, "Series") && strlength(this.Data.Comment(1))>0
                caption = string(this.Data.Comment(1));
                if parent.ShowFormulas
                    caption = [caption; hereCreateFormula()];
                end
            elseif ~ismissing(this.Expression) && strlength(this.Expression)>0
                caption = hereCreateFormula();
            else
                caption = string(missing);
            end
            if ~ismissing(parent.NewLine) && strlength(parent.NewLine)>0
                caption = strip(split(caption, parent.NewLine));
            end

            function formula = hereCreateFormula()
                formula = this.Expression;
                transform = getTransform(this);
                if ~isempty(transform) && parent.ShowTransform
                    formula(1) = formula(1) + "; " + string(func2str(this.Transform));
                end
            end%
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
            temp = strip(split(inputString, databank.chartpack.Chart.SEPARATE_CAPTION));
            if numel(temp)==1
                caption = "";
                expression = temp;
            else
                caption = temp(1);
                expression = join(temp(2:end), databank.chartpack.Chart.SEPARATE_CAPTION);
            end
            applyTransform = true;
            if startsWith(expression, databank.chartpack.Chart.EXCLUDE_FROM_TRANSFORM)
                expression = extractAfter(expression, 1);
                applyTransform = false;
            end
            %)
        end%
    end
end

