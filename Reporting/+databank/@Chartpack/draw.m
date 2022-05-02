
%{
---
title: draw
---

# `draw`

{== Render charts defined in Chartpack ==}


## Syntax

    info = draw(ch, inputDb)


## Input arguments

__`ch`__ [ Chartpack ]
>
> Chartpack object whose charts will be rendered on the screen.
>


__`inputDb`__ [ struct | Dictionary ]
>
> Input databank within which the expressions defining the charts will be
> evaluated, and the results plotted.
>

## Output arguments

__`info`__ [ struct ]
>
> Output information structure with the following fields:
>
> * `.FigureHandles` - handles to all figure objects created;
>
> * `.AxesHandles` - cell array of handles to all axes objects created,
>   grouped by figures;
>
> * `.PlotHandles` - cell array of cell arrays of handles to all objects
>   plotted within axes, grouped by figures and by axes;
>
> * `.TitleHandles` - cell array of handles to all title objects created,
>   grouped by figures;
>
> * `.SubtitleHandles` - cell array of handles to all subtitle objects
>   created, grouped by figures;
>

## Description


## Examples

%}


function info = draw(this, inputDb)

% >=R2019b
%(
arguments
    this (1, 1) databank.Chartpack
    inputDb (1, 1) {validate.mustBeDatabank}
end
%)
% >=R2019b


tiles = resolveTiles(this);
numTilesPerWindow = prod(tiles);

range = this.Range;
if ~iscell(range)
    range = {range};
end

for x = this.Charts
    evaluate(x, inputDb);
end

figureHandles = gobjects(1, 0);
axesHandles = cell(1, 0);
titleHandles = cell(1, 0);
subtitleHandles = cell(1, 0);
plotHandles = cell(1, 0);

countFigures = 0;
countChartsInWindow = 0;
currentFigure = gobjects(0);
for x = this.Charts
    if x.PageBreak
        countChartsInWindow = 0;
        continue
    end
    if countChartsInWindow==0
        if ~isempty(currentFigure)
            runFigureExtras(this, currentFigure);
        end
        currentFigure = figure(this.FigureSettings{:});
        countFigures = countFigures + 1;
        if length(this.FigureTitle)==1
            visual.heading(this.FigureTitle);
        elseif length(this.FigureTitle)>=countFigures
            visual.heading(this.FigureTitle(countFigures));
        end
        figureHandles(end+1) = currentFigure;
        axesHandles{end+1} = gobjects(1, 0);
        titleHandles{end+1} = gobjects(1, 0);
        subtitleHandles{end+1} = gobjects(1, 0);
        plotHandles{end+1} = cell(1, 0);
    end
    countChartsInWindow = countChartsInWindow + 1;
    currentAxes = subplot(tiles(1), tiles(2), countChartsInWindow);
    axesHandles{end}(end+1) = currentAxes;
    if this.Round<Inf
        x.Data = round(x.Data, this.Round);
    end
    plotHandles__ = this.PlotFunc(range{:}, x.Data);
    runPlotExtras(x, plotHandles__);
    plotHandles{end}{end+1} = plotHandles__;

    [titleHandles{end}(end+1), subtitleHandles{end}(end+1)] ...
        = local_createTitle(x, currentAxes);

    local_drawBackground(x);

    runAxesExtras(x, currentAxes);

    if countChartsInWindow==numTilesPerWindow
        countChartsInWindow = 0;
    end
end

if ~isempty(currentFigure)
    runFigureExtras(this, currentFigure);
end


info = struct();
info.FigureHandles = figureHandles;
info.AxesHandles = axesHandles;
info.TitleHandles = titleHandles;
info.SubtitleHandles = subtitleHandles;
info.PlotHandles = plotHandles;

if ~isempty(figureHandles)
    showFigure = this.ShowFigure;
    if isequal(showFigure, Inf)
        showFigure = numel(figureHandles);
    end
    figure(figureHandles(showFigure));
end

end%

%
% Local Functions
%

function [titleHandle, subtitleHandle] = local_createTitle(x, currentAxes)
    %(
    PLACEHOLDER = gobjects(1);
    parent = x.ParentChartpack;
    caption = resolveCaption(x);
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


function local_drawBackground(x)
    %(
    parent = x.ParentChartpack;
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


%#ok<*AGROW>

