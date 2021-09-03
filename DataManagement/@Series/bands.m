function [plotHandle, bandsHandles, dates, midData, xCoor] ...
    = bands(mid, lower, upper, options, bandsOptions)

arguments
    mid Series
    lower Series
    upper Series

    options.Range {validate.mustBeDate} = [-Inf, Inf]
    options.AxesHandle (1, 1) = @gca
    options.PlotSettings (1, :) cell = cell.empty(1, 0)
    options.Layer = 'top'

    bandsOptions.White (1, 1) double {mustBeInRange(bandsOptions.White, 0, 1)} = 0.85
    bandsOptions.Relative (1, 1) logical = true
    bandsOptions.ExcludeFromLegend (1, 1) logical = true
end


axesHandle = options.AxesHandle;
if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle();
end

[plotHandle, dates, midData, axesHandle, xCoor] ...
    = Series.implementPlot(@plot, axesHandle, options.Range, mid, '', options.PlotSettings{:});

lowerData = getData(lower, dates);
upperData = getData(upper, dates);
bandsHandles = series.bands(axesHandle, plotHandle, midData, xCoor, lowerData, upperData, bandsOptions);

set(axesHandle, 'layer', options.Layer);

end%

