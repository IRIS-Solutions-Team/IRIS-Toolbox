function [plotHandles, unitHandle, quadrantHandles] = eigen(x, options)


arguments
    x (:, :, :) double

    options.PlotSettings (1, :) cell = {"lineStyle", "none", "marker", "s", "markerSize", 12, "lineWidth", 3}
    options.UnitCircle (1, 1) logical = true
    options.UnitCircleSettings (1, :) cell = {"color", 0.5*[1, 1, 1]}
end


if size(x, 1)==1 && size(x, 3)>1 
    x = reshape(x, size(x, 2), size(x, 3), 1);
end

plotHandles = plot(real(x), imag(x), options.PlotSettings{:});

if options.UnitCircle
    ax = gca( );
    nextPlot = get(ax, "nextplot");
    set(ax, "nextPlot", "add");
    unitHandle = locallyPlotUnitCircle(ax, options);  
    xline(0);
    yline(0);
    visual.excludeFromLegend(unitHandle);
    visual.backend.moveToBackground(unitHandle);
    set(ax, "nextPlot", nextPlot);
end

end%

%
% Local functions
%

function unitHandle = locallyPlotUnitCircle(ax, options)
    %(
    n = 128;
    th = 2*pi*(0:n)/n;
    unitHandle = plot(cos(th), sin(th), options.UnitCircleSettings{:});
    label = cellstr(get(gca, "yTickLabel"));
    label = regexprep(label, "\s*([\+-\.\d]+).*", "$1 i");
    set(gca, "yTickLabel", label, "yTickMode", "manual");
    axis equal
    %)
end%  

