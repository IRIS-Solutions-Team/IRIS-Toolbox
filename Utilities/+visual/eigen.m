
% >=R2019b
%{
function [plotHandles, unitHandle] = eigen(x, opt)

arguments
    x (:, :, :) double

    opt.PlotSettings (1, :) cell = {"lineStyle", "none", "marker", "s", "markerSize", 12, "lineWidth", 3}
    opt.UnitCircle (1, 1) logical = true
    opt.UnitCircleSettings (1, :) cell = {"color", 0.5*[1, 1, 1]}
end
%}
% >=R2019b


% <=R2019a
%(
function [plotHandles, unitHandle] = eigen(x, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "PlotSettings", {"lineStyle", "none", "marker", "s", "markerSize", 12, "lineWidth", 3});
    addParameter(ip, "UnitCircle", true);
    addParameter(ip, "UnitCircleSettings", {"color", 0.5*[1, 1, 1]});
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


if size(x, 1)==1 && size(x, 3)>1 
    x = reshape(x, size(x, 2), size(x, 3), 1);
end

plotHandles = plot(real(x), imag(x), opt.PlotSettings{:});

if opt.UnitCircle
    ax = gca();
    nextPlot = get(ax, "nextplot");
    set(ax, "nextPlot", "add");
    unitHandle = local_plotUnitCircle(ax, opt);  
    visual.vline(0);
    visual.hline(0);
    visual.excludeFromLegend(unitHandle);
    visual.backend.moveToBackground(unitHandle);
    set(ax, "nextPlot", nextPlot);
end

end%

%
% Local functions
%

function unitHandle = local_plotUnitCircle(ax, opt)
    %(
    n = 128;
    th = 2*pi*(0:n)/n;
    unitHandle = plot(ax, cos(th), sin(th), opt.UnitCircleSettings{:});
    label = cellstr(get(gca, "yTickLabel"));
    label = regexprep(label, "\s*([\+-\.\d]+).*", "$1 i");
    set(ax, "yTickLabel", label, "yTickMode", "manual");
    axis equal
    %)
end%  

