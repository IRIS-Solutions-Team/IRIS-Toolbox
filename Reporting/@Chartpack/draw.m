
function info = draw(this, inputDb)

% >=R2019b
%{
arguments
    this (1, 1) Chartpack
    inputDb (1, 1) {validate.mustBeDatabank}
end
%}
% >=R2019b

%
% Parse input strings into Chart objects
%

info = struct();
info.FigureHandles = gobjects(1, 0);
info.AxesHandles = cell(1, 0);
info.TitleHandles = cell(1, 0);
info.SubtitleHandles = cell(1, 0);
info.PlotHandles = cell(1, 0);

chartObjects = chartpack.Chart.fromString(this.Charts);
if isempty(chartObjects)
    return
end
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
        info.FigureHandles(end+1) = currentFigure;
        info.AxesHandles{end+1} = gobjects(1, 0);
        info.TitleHandles{end+1} = gobjects(1, 0);
        info.SubtitleHandles{end+1} = gobjects(1, 0);
        info.PlotHandles{end+1} = cell(1, 0);
    end
    countChartsInWindow = countChartsInWindow + 1;

    if x.Empty
        continue
    end

    currentAxes = subplot(tiles(1), tiles(2), countChartsInWindow);
    info.AxesHandles{end}(end+1) = currentAxes;

    chartInfo = draw(x, range, currentAxes);
    info.PlotHandles{end}{end+1} = chartInfo.PlotHandles;
    info.TitleHandles{end}(end+1) = chartInfo.TitleHandle;
    info.SubtitleHandles{end}(end+1) = chartInfo.SubtitleHandle;

    if countChartsInWindow==numTilesPerWindow
        countChartsInWindow = 0;
    end
end

if ~isempty(currentFigure)
    runFigureExtras(this, currentFigure);
end

if ~isempty(info.FigureHandles) && ~isnan(this.ShowFigure)
    showFigure = this.ShowFigure;
    if isequal(showFigure, Inf)
        showFigure = numel(info.FigureHandles);
    end
    figure(info.FigureHandles(showFigure));
end

end%

