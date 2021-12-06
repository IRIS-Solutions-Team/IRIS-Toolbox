
% >=R2019b
%(
function [plotHandles, axesHandle, diffPlotHandle] = diffChart(inputSeries, opt)

arguments
    inputSeries (:, 2) Series

    opt.Range = Inf
    opt.Axes = "current"
    opt.DiffFunc = @minus
    opt.PlotFunc = @plot
    opt.DiffPlotFunc = @bar
    opt.Transform = []
    opt.FirstPlot (1, :) cell = cell.empty(1, 0)
    opt.SecondPlot (1, :) cell = cell.empty(1, 0)
    opt.DiffPlot (1, :) cell = {"lineStyle", "none", "faceAlpha", 0.75}
end
%}
% >=R2019b


% <=R2019a
%(
function [axesHandle, plotHandles, diffPlotHandle] = diffChart(inputSeries, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addParameter(pp, 'Range', Inf);
    addParameter(pp, 'Axes', "current");
    addParameter(pp, 'DiffFunc', @minus);
    addParameter(pp, 'PlotFunc', @plot);
    addParameter(pp, 'DiffPlotFunc', @bar);
    addParameter(pp, 'Transform', []);
    addParameter(pp, 'FirstPlot', cell.empty(1, 0));
    addParameter(pp, 'SecondPlot', cell.empty(1, 0));
    addParameter(pp, 'DiffPlot', {'lineStyle', 'none', 'faceAlpha', 0.75});
end
parse(pp, varargin{:});
opt = pp.Results;
%)
% <=R2019a


axesHandle = locallyPrepareAxes(opt);

[firstSeries, secondSeries, diffSeries] = locallyPrepareSeries(inputSeries, opt);

plotHandles = plot(opt.Range, [firstSeries, secondSeries]);

currentLocation = string(axesHandle.YAxisLocation);
if startsWith(currentLocation, "left", "ignoreCase", true)
    targetLocation = "right";
else
    targetLocation = "left";
end
yyaxis(targetLocation);

diffPlotHandle = opt.DiffPlotFunc(opt.Range, diffSeries);

yyaxis(currentLocation);


if ~isempty(opt.FirstPlot)
    set(plotHandles(1), opt.FirstPlot{:});
end

if ~isempty(opt.SecondPlot)
    set(plotHandles(2), opt.SecondPlot{:});
end

if ~isempty(opt.DiffPlot)
    set(diffPlotHandle, opt.DiffPlot{:});
end

end%

%
% Local Functions
%

function axesHandle = locallyPrepareAxes(opt)
    %(
    if isstring(opt.Axes) && startsWith(opt.Axes, "current")
        axesHandle = visual.backend.getCurrentAxesIfExists();
    end
    if isempty(axesHandle)
        axesHandle = axes();
    end
    %)
end%


function [firstSeries, secondSeries, diffSeries] = locallyPrepareSeries(inputSeries, opt)
    %(
    firstSeries = retrieveColumns(inputSeries, 1);
    secondSeries = retrieveColumns(inputSeries, 2);
    if ~isempty(opt.Transform)
        firstSeries = opt.Transform(firstSeries);
        secondSeries = opt.Transform(secondSeries);
    end
    diffSeries = opt.DiffFunc(secondSeries, firstSeries);
    %)
end%

