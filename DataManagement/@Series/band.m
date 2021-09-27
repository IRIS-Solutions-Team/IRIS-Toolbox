function [plotHandle, bandHandles, dates, midData, xCoor] ...
    = band(mid, lower, upper, options, bandOptions)

arguments
    mid Series
    lower Series
    upper Series

    options.Range {validate.mustBeDate} = [-Inf, Inf]
    options.AxesHandle (1, 1) = @gca
    options.PlotSettings (1, :) cell = cell.empty(1, 0)
    options.Layer = 'top'

    bandOptions.White (1, 1) double {mustBeInRange(bandOptions.White, 0, 1)} = 0.85
    bandOptions.Relative (1, 1) logical = true
    bandOptions.ExcludeFromLegend (1, 1) logical = true
end


axesHandle = options.AxesHandle;
if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle();
end

[plotHandle, dates, midData, axesHandle, xCoor] ...
    = Series.implementPlot(@plot, axesHandle, options.Range, mid, '', options.PlotSettings{:});

lowerData = getData(lower, dates);
upperData = getData(upper, dates);
bandHandles = series.band(axesHandle, plotHandle, midData, xCoor, lowerData, upperData, bandOptions);

set(axesHandle, 'layer', options.Layer);

end%

