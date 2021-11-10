function info = draw(this, inputDb, varargin)

% >=R2019b
%(
arguments
    this (1, 1) databank.Chartpack
    inputDb (1, 1) {validate.mustBeDatabank}
end

arguments (Repeating)
    varargin
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
        = locallyCreateTitle(x, currentAxes);

    locallyHighlight(x, currentAxes);

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

function [titleHandle, subtitleHandle] = locallyCreateTitle(x, currentAxes)
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


function locallyHighlight(x, currentAxes)
    %(
    parent = x.ParentChartpack;
    if isempty(parent.Highlight)
        return
    end
    visual.highlight(currentAxes, parent.Highlight);
    %)
end%

%#ok<*AGROW>
