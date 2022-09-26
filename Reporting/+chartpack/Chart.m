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

        PageBreak (1, 1) logical = false
        Empty (1, 1) logical = false
    end


    properties (SetAccess=protected)
        ExpressionExpanded (1, 1) string = ""
    end


    properties (Constant)
        SEPARATE_CAPTION = ":"
        EXCLUDE_FROM_TRANSFORM = "^"
        EXPANSION_MARK = "?"
        PAGE_BREAK = ["//", "---"]
    end


    methods
        function this = Chart(varargin)
            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end
        end%


        function info = draw(this, range, currentAxes)
            %(
            parent = this.ParentChartpack;

            dataToPlot = this.Data;
            if parent.Round<Inf
                dataToPlot = round(dataToPlot, parent.Round);
            end
            plotHandles = parent.PlotFunc(range{:}, dataToPlot);

            runPlotExtras(this, plotHandles);

            [titleHandle, subtitleHandle] = createTitle(this, currentAxes);

            drawGrid(this, currentAxes);
            drawBackground(this);

            runAxesExtras(this, currentAxes);

            if parent.ClickToExpand
                visual.clickToExpand(currentAxes);
            end

            info = struct();
            info.PlotHandles = plotHandles;
            info.TitleHandle = titleHandle;
            info.SubtitleHandle = subtitleHandle;
            %)
        end%


        function [titleHandle, subtitleHandle] = createTitle(this, currentAxes)
            %(
            PLACEHOLDER = gobjects(1);
            parent = this.ParentChartpack;
            caption = resolveCaption(this);
            if ~ismissing(caption)
                try
                    [titleHandle, subtitleHandle] = title(currentAxes, caption(1), caption(2:end));
                catch
                    titleHandle = title(currentAxes, caption);
                    subtitleHandle = PLACEHOLDER;
                end
                set(titleHandle, "interpreter", parent.Interpreter, parent.TitleSettings{:});
                if numel(caption)>1 && ~isempty(subtitleHandle) && ~isequal(subtitleHandle, PLACEHOLDER)
                    set(subtitleHandle, "interpreter", parent.Interpreter, parent.SubtitleSettings{:});
                end
            else
                titleHandle = gobjects(1);
            end
            %)
        end%


        function drawGrid(this, currentAxes)
            %(
            parent = this.ParentChartpack;
            if parent.Grid(1)
                set(currentAxes, 'XGrid', 'on');
            else
                set(currentAxes, 'XGrid', 'off');
            end
            if parent.Grid(2)
                set(currentAxes, 'YGrid', 'on');
            else
                set(currentAxes, 'YGrid', 'off');
            end
            %)
        end%


        function drawBackground(this)
            %(
            parent = this.ParentChartpack;
            if ~isempty(parent.Highlight)
                visual.highlight(parent.Highlight);
            end
            if ~isempty(parent.XLine)
                visual.xline(parent.XLine{1}, parent.XLine{2:end});
            end
            if ~isempty(parent.YLine)
                visual.yline(parent.YLine{1}, parent.YLine{2:end});
            end
            %)
        end%


        function setParent(this, parent)
            for x = reshape(this, 1, [])
                x.ParentChartpack = parent;
            end
        end%


        function n = getMaxNumCharts(this)
            if isempty(this)
                n = 0;
                return
            end
            inxPageBreaks = [this.PageBreak];
            if ~any(inxPageBreaks)
                n = numel(this);
                return
            end
            if inxPageBreaks(1)==false
                inxPageBreaks = [true, inxPageBreaks];
            end
            if inxPageBreaks(end)==false
                inxPageBreaks = [inxPageBreaks, true];
            end
            n = max(diff(find(inxPageBreaks)) - 1);
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
            expand(this);
            if this.Empty
                return
            end
            this.Data = databank.eval(inputDb, this.ExpressionExpanded);
            if this.ApplyTransform
                transform = getTransform(this);
                if ~isempty(transform)
                    this.Data = transform(this.Data);
                end
            end
        end%


        function this = expand(this, expression)
            expression = this.Expression;
            if ismissing(expression) || expression==""
                this.Empty = true;
                this.Expression = "";
                this.ExpressionExpanded = "";
                return
            end
            expansion = getExpansion(this);
            if ~isempty(expansion)
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
            end
            this.ExpressionExpanded = expression;
        end%


        function caption = resolveCaption(this)
            parent = this.ParentChartpack;
            if ~ismissing(this.Caption) && strlength(this.Caption)>0
                caption = here_splitCaption(this.Caption, parent.NewLine);
                if parent.ShowFormulas
                    caption = [caption; here_createFormula()];
                end
            elseif parent.Autocaption && isa(this.Data, 'Series') && strlength(this.Data.Comment(1))>0
                caption = here_splitCaption(string(this.Data.Comment(1)), parent.NewLine);
                if parent.ShowFormulas
                    caption = [caption; here_createFormula()];
                end
            elseif ~ismissing(this.Expression) && strlength(this.Expression)>0
                caption = here_createFormula();
            else
                caption = string(missing);
            end

            function formula = here_createFormula()
                formula = this.ExpressionExpanded;
                transform = getTransform(this);
                if ~isempty(transform) && parent.ShowTransform
                    formula(1) = formula(1) + "; " + string(func2str(this.Transform));
                end
            end%

            function caption = here_splitCaption(caption, newLine)
                if ~ismissing(newLine) && strlength(newLine)>0
                    caption = strip(split(caption, newLine));
                end
            end%
        end%


        function runAxesExtras(this, axesHandle)
            %(
            parent = this.ParentChartpack;
            if ~isempty(parent.AxesSettings)
                set(axesHandle, parent.AxesSettings{:});
            end
            for i = 1 : numel(parent.AxesExtras)
                parent.AxesExtras{i}(axesHandle);
            end
            %)
        end%


        function runPlotExtras(this, plotHandles)
            %(
            parent = this.ParentChartpack;            
            if ~isempty(parent.PlotSettings)
                for i = 1 : 2 : numel(parent.PlotSettings)
                    try
                        set(plotHandles, parent.PlotSettings{i:i+1});
                    end
                end
            end
            for i = 1 : numel(parent.PlotExtras)
                try
                    parent.PlotExtras{i}(plotHandles);
                end
            end
            %)
        end%
    end


    methods (Static)
        function this = fromString(inputString, varargin)
% >=R2019b
%{
            arguments
                inputString (1, :) string
            end
            arguments (Repeating)
                varargin
            end
%}
% >=R2019b

            inputString = textual.stringify(inputString);
            this = [];
            for n = inputString
                temp = chartpack.Chart(varargin{:});
                temp.InputString = strip(n);
                if startsWith(temp.InputString, "%")
                    continue
                elseif any(temp.InputString==chartpack.Chart.PAGE_BREAK)
                    temp.PageBreak = true;
                else
                    [temp.Caption, temp.Expression, temp.ApplyTransform] ...
                        = chartpack.Chart.parseInputString(temp.InputString);
                end
                this = [this, temp];
            end
            %)
        end%


        function [caption, expression, applyTransform] = parseInputString(inputString)
% >=R2019b
%{
            arguments
                inputString (1, 1) string
            end
%}
% >=R2019b

            inputString = string(inputString);
            temp = strip(split(inputString, chartpack.Chart.SEPARATE_CAPTION));
            if numel(temp)==1
                caption = "";
                expression = temp;
            else
                caption = temp(1);
                expression = join(temp(2:end), chartpack.Chart.SEPARATE_CAPTION);
            end
            applyTransform = true;
            if startsWith(expression, chartpack.Chart.EXCLUDE_FROM_TRANSFORM)
                expression = extractAfter(expression, 1);
                applyTransform = false;
            end
            %)
        end%
    end
end

%#ok<*AGROW>
