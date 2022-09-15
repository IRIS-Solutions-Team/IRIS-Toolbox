
% >=R2019b
%{
function info = plotNeighbors(this, d, opt)

arguments
    this (1, 1) poster
    d (1, 1) struct

    opt.PlotPosterior = cell.empty(1, 0)
    opt.PlotModeEstimate = cell.empty(1, 0)
    opt.PlotDataLik = cell.empty(1, 0)
    opt.PlotIndiePriors = cell.empty(1, 0)
    opt.PlotSystemPriors = cell.empty(1, 0)
    opt.PlotBounds = cell.empty(1, 0)
    opt.Figure (1, :) cell = cell.empty(1, 0)
    opt.Title = cell.empty(1, 0)
    opt.Tiles = @auto
    opt.Captions (1, :) string = string.empty(1, 0)
    opt.LinkYAxes (1, 1) logical = false
end
%}
% >=R2019b


% <=R2019a
%(
function info = plotNeighbors(this, d, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "PlotPosterior", cell.empty(1, 0));
    addParameter(ip, "PlotModeEstimate", cell.empty(1, 0));
    addParameter(ip, "PlotDataLik", cell.empty(1, 0));
    addParameter(ip, "PlotIndiePriors", cell.empty(1, 0));
    addParameter(ip, "PlotSystemPriors", cell.empty(1, 0));
    addParameter(ip, "PlotBounds", cell.empty(1, 0));
    addParameter(ip, "Figure", cell.empty(1, 0));
    addParameter(ip, "Title", cell.empty(1, 0));
    addParameter(ip, "Tiles", @auto);
    addParameter(ip, "Captions", string.empty(1, 0));
    addParameter(ip, "LinkYAxes", false);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


%#ok<*AGROW>

needsPlotPosterior = ~isequal(opt.PlotPosterior, false);
needsPlotModeEstimate = ~isequal(opt.PlotModeEstimate, false);
needsPlotDataLik = ~isequal(opt.PlotDataLik, false);
needsPlotIndiePriors = ~isequal(opt.PlotIndiePriors, false);
needsPlotSystemPriors = ~isequal(opt.PlotSystemPriors, false);
needsPlotBounds = ~isequal(opt.PlotBounds, false);
needsTitle = ~isequal(opt.Title, false);

info = struct();
info.FigureHandles = gobjects(1, 0);
info.AxesHandles = gobjects(1, 0);
info.PosteriorHandles = gobjects(1, 0);
info.ModeEstimateHandles = gobjects(1, 0);
info.DataLikHandles = gobjects(1, 0);
info.IndiePriorHandles = gobjects(1, 0);
info.SystemPriorHandles = gobjects(1, 0);
info.LowerBoundHandles = gobjects(1, 0);
info.UpperBoundHandles = gobjects(1, 0);
info.TitleHandles = gobjects(1, 0);

parameterNames = textual.stringify(this.ParameterNames);
numParameters = numel(parameterNames);

if isequal(opt.Tiles, @auto)
    [numRows, numColumns] = visual.backend.optimizeSubplot(numParameters);
    opt.Tiles = [numRows, numColumns];
end
numTilesPerFigure = prod(opt.Tiles);


%
% Prepare plot opt
%

plotPosteriorOptions = cell.empty(1, 0);
plotModeEstimateOptions = cell.empty(1, 0);
plotDataLikOptions = cell.empty(1, 0);
plotIndiePriorsOptions = cell.empty(1, 0);
plotSystemPriorsOptions = cell.empty(1, 0);
plotBoundsOptions = cell.empty(1, 0);
titleOptions = cell.empty(1, 0);
herePreparePlotSettings( );

yLim = nan(numParameters, 2);

% Force a new figure window.
count = numTilesPerFigure + 1;

if needsTitle
    captions = herePopulateCaptions();  
end

for i = 1 : numParameters
    count = count + 1;

    if count>numTilesPerFigure
        count = 1;
        info.FigureHandles(end+1) = figure(opt.Figure{:});
    end

    info.AxesHandles(end+1) = subplot(opt.Tiles(1), opt.Tiles(2), count); 
    hold all

    x = d.(parameterNames(i)){1}(:, 1);
    xMin = min(x);
    xMax = max(x);

    % Posterior and its breakdown (minus log density)
    yPosterior = d.(parameterNames(i)){3}(:, 1);
    yDataLik = d.(parameterNames(i)){3}(:, 2);
    yIndiePriors = d.(parameterNames(i)){3}(:, 3);
    ySystemPriors = d.(parameterNames(i)){3}(:, 4);

    % Mode estimate
    xModeEstimate = d.(parameterNames(i)){4}(1);
    yModeEstimate = d.(parameterNames(i)){4}(2);

    if needsPlotPosterior
        info.PosteriorHandles(end+1) = plot(x, yPosterior, plotPosteriorOptions{:}); 
    end

    if needsPlotModeEstimate
        info.ModeEstimateHandles(end+1) = plot( ...
            xModeEstimate, 0 ...
            , "lineStyle", "none" ...
            , "marker", "s" ...
            , plotModeEstimateOptions{:} ...
        ); 
    end

    if needsPlotDataLik
        info.DataLikHandles(end+1) = plot(x, yDataLik, plotDataLikOptions{:}); 
    end

    if needsPlotIndiePriors
        info.IndiePriorHandles(end+1) = plot(x, yIndiePriors, plotIndiePriorsOptions{:}); 
    end

    if needsPlotSystemPriors
        info.SystemPriorHandles(end+1) = plot(x, ySystemPriors, plotSystemPriorsOptions{:}); 
    end

    if needsPlotBounds
        lowerBound = d.(parameterNames(i)){4}(3);
        upperBound = d.(parameterNames(i)){4}(4);
        if lowerBound>=xMin && lowerBound<=xMax
            info.LowerBoundHandles(end+1) = visual.vline( ...
                lowerBound ...
                , "marker", ">" ...
                , plotBoundsOptions{:} ...
            ); 
        else
            info.LowerBoundHandles(end+1) = gobjects(1, 1);
        end

        if upperBound>=xMin && upperBound<=xMax
            info.UpperBoundHandles(end+1) = visual.vline( ...
                upperBound ...
                , "marker", "<" ...
                , plotBoundsOptions{:} ...
            ); 
        else
            info.UpperBoundHandles(end+1) = gobjects(1, 1);
        end
    end

    grid on

    if needsTitle
        info.TitleHandles(end+1) = title( ...
            captions(i) ...
            , "interpreter", "none" ...
            , titleOptions{:} ...
        );
    end

    axis tight
    yLim(i, :) = get(info.AxesHandles(end), "yLim");

    try %#ok<TRYNC>
        set(info.AxesHandles(end), "xLim", [xMin, xMax]);
    end
end

if opt.LinkYAxes
    % Sort ylims by the total coverage.
    [~, inx] = sort(yLim*[-1;1]); %#ok<*NOANS, *ASGLU>
    yLim = yLim(inx, :);
    linkaxes(info.AxesHandles, "y");
    % Set ylims to the median coverage.
    set(info.AxesHandles(end), 'yLim', yLim(ceil(numParameters/2), :));
end

return

    function herePreparePlotSettings( )
        if iscell(opt.PlotPosterior)
            plotPosteriorOptions = opt.PlotPosterior;
        end

        if iscell(opt.PlotModeEstimate)
            plotModeEstimateOptions = opt.PlotModeEstimate;
        end

        if iscell(opt.PlotDataLik) 
            plotDataLikOptions = opt.PlotDataLik;
        end

        if iscell(opt.PlotIndiePriors) 
            plotIndiePriorOptions = opt.PlotIndiePriors;
        end

        if iscell(opt.PlotSystemPriors) 
            plotSystemPriorOptions = opt.PlotSystemPriors;
        end

        if iscell(opt.PlotBounds)
            plotBoundsOptions = opt.PlotBounds;
        end

        if iscell(opt.Title) 
            titleOptions = opt.Title;
        end
    end%


    function captions = herePopulateCaptions()
        captions = parameterNames;
        n = numel(opt.Captions);
        captions(1:n) = opt.Captions(1:n);
    end%
end%


