function info = draw(this, inputDb, varargin)

arguments
    this (1, 1) databank.Chartpack
    inputDb (1, 1) {validate.mustBeDatabank}
end

arguments (Repeating)
    varargin
end

tiles = resolveTiles(this);
numTilesPerWindow = prod(tiles);
range = this.Range;

for x = this.Charts
    evaluate(x, inputDb);
end

figureHandles = gobjects(1, 0);
axesHandles = cell(1, 0);
titleHandles = cell(1, 0);
subtitleHandles = cell(1, 0);
plotHandles = cell(1, 0);

countChartsInWindow = 0;
for x = this.Charts
    if countChartsInWindow==0
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
    plotHandles{end}{end+1} = this.PlotFunc(range, x.Data, this.PlotSettings{:});    

    [titleHandles{end}(end+1), subtitleHandles{end}(end+1)] ...
        = locallyCreateTitle(x, currentAxes);
    
    locallyHighlight(x, currentAxes);
    
    runAxesExtras(x, currentAxes);

    if countChartsInWindow==numTilesPerWindow
        countChartsInWindow = 0;
    end
end

info = struct();
info.FigureHandles = figureHandles;
info.AxesHandles = axesHandles;
info.TitleHandles = titleHandles;
info.SubtitleHandlens = subtitleHandles;
info.PlotHandles = plotHandles;

end%

%
% Local Functions
%

function [titleHandle, subtitleHandle] = locallyCreateTitle(x, currentAxes) 
    %(
    parent = x.ParentChartpack;
    caption = resolveCaption(x);
    if ~ismissing(caption)
        [titleHandle, subtitleHandle] = title(currentAxes, caption(1), caption(2:end));
        set(titleHandle, "interpreter", parent.Interpreter, parent.TitleSettings{:});
        if numel(caption)>1
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
