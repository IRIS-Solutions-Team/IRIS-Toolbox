function info = plotNeighbors(this, d, options)

arguments
    this (1, 1) poster
    d (1, 1) struct

    options.PlotPosterior = cell.empty(1, 0)
    options.PlotModeEstimate = cell.empty(1, 0)
    options.PlotDataLik = cell.empty(1, 0)
    options.PlotIndiePriors = cell.empty(1, 0)
    options.PlotSystemPriors = cell.empty(1, 0)
    options.PlotBounds = cell.empty(1, 0)
    options.Figure (1, :) cell = cell.empty(1, 0)
    options.Title = cell.empty(1, 0)
    options.Tiles = @auto
    options.Captions (1, :) string = string.empty(1, 0)
    options.LinkYAxes (1, 1) logical = true
end

%#ok<*AGROW>

needsPlotPosterior = ~isequal(options.PlotPosterior, false);
needsPlotModeEstimate = ~isequal(options.PlotModeEstimate, false);
needsPlotDataLik = ~isequal(options.PlotDataLik, false);
needsPlotIndiePriors = ~isequal(options.PlotIndiePriors, false);
needsPlotSystemPriors = ~isequal(options.PlotSystemPriors, false);
needsPlotBounds = ~isequal(options.PlotBounds, false);
needsTitle = ~isequal(options.Title, false);

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

if isequal(options.Tiles, @auto)
    [numRows, numColumns] = visual.backend.optimizeSubplot(numParameters);
    options.Tiles = [numRows, numColumns];
end
numTilesPerFigure = prod(options.Tiles);


%
% Prepare plot options
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
        info.FigureHandles(end+1) = figure(options.Figure{:});
    end

    info.AxesHandles(end+1) = subplot(options.Tiles(1), options.Tiles(2), count); 
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
            xModeEstimate, yModeEstimate ...
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
            info.LowerBoundHandles(end+1) = xline( ...
                lowerBound ...
                , "marker", ">" ...
                , plotBoundsOptions{:} ...
            ); 
        else
            info.LowerBoundHandles(end+1) = gobjects(1, 1);
        end

        if upperBound>=xMin && upperBound<=xMax
            info.UpperBoundHandles(end+1) = xline( ...
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

if options.LinkYAxes
    % Sort ylims by the total coverage.
    [~, inx] = sort(yLim*[-1;1]); %#ok<*NOANS, *ASGLU>
    yLim = yLim(inx, :);
    linkaxes(info.AxesHandles, "y");
    % Set ylims to the median coverage.
    set(info.AxesHandles(end), 'yLim', yLim(ceil(numParameters/2), :));
end

return

    function herePreparePlotSettings( )
        if iscell(options.PlotPosterior)
            plotPosteriorOptions = options.PlotPosterior;
        end

        if iscell(options.PlotModeEstimate)
            plotModeEstimateOptions = options.PlotModeEstimate;
        end

        if iscell(options.PlotDataLik) 
            plotDataLikOptions = options.PlotDataLik;
        end

        if iscell(options.PlotIndiePriors) 
            plotIndiePriorOptions = options.PlotIndiePriors;
        end

        if iscell(options.PlotSystemPriors) 
            plotSystemPriorOptions = options.PlotSystemPriors;
        end

        if iscell(options.PlotBounds)
            plotBoundsOptions = options.PlotBounds;
        end

        if iscell(options.Title) 
            titleOptions = options.Title;
        end
    end%


    function captions = herePopulateCaptions()
        captions = parameterNames;
        n = numel(options.Captions);
        captions(1:n) = options.Captions(1:n);
    end%
end%


