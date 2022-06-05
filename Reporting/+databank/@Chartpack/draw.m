
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

%
% Parse input strings into Chart objects
%
chartObjects = databank.chartpack.Chart.fromString(this.Charts);
setParent(chartObjects, this);


tiles = resolveTiles(this, chartObjects);
numTilesPerWindow = prod(tiles);

range = this.Range;
if ~iscell(range)
    range = {range};
end

for x = chartObjects
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
for x = reshape(chartObjects, 1, [])
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

    if x.Empty
        continue
    end

    currentAxes = subplot(tiles(1), tiles(2), countChartsInWindow);
    axesHandles{end}(end+1) = currentAxes;

    chartInfo = draw(x, range, currentAxes);
    plotHandles{end}{end+1} = chartInfo.PlotHandles;
    titleHandles{end}(end+1) = chartInfo.TitleHandle;
    subtitleHandles{end}(end+1) = chartInfo.SubtitleHandle;

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

if ~isempty(figureHandles) && ~isnan(this.ShowFigure)
    showFigure = this.ShowFigure;
    if isequal(showFigure, Inf)
        showFigure = numel(figureHandles);
    end
    figure(figureHandles(showFigure));
end

end%

