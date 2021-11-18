function [plotHandle, bandHandles, dates, midData, xCoor] ...
    = band(mid, lower, upper, options, bandOptions)

arguments
    mid Series
    lower {locallyValidateBounds} = []
    upper {locallyValidateBounds} = []

    options.Range {validate.mustBeDate} = [-Inf, Inf]
    options.AxesHandle (1, 1) = @gca
    options.PlotSettings (1, :) cell = cell.empty(1, 0)
    options.Layer = 'top'

    bandOptions.White (1, 1) double {mustBeInRange(bandOptions.White, 0, 1)} = 0.85
    bandOptions.Relative (1, 1) logical = true
    bandOptions.ExcludeFromLegend (1, 1) logical = true
end


if isequal(lower, []) && isequal(upper, [])
    lower = retrieveColumns(mid, 2);
    if size(mid.Data, 2)>2
        upper = retrieveColumns(mid, 3);
    end
    mid = retrieveColumns(mid, 1);
end

if isequal(upper, [])
    upper = lower;
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

%
% Local validators
%

function locallyValidateBounds(x)
    %(
    if isa(x, 'Series') || isequal(x, [])
        return
    end
    error("Input value must be a time series.");
    %)
end%



