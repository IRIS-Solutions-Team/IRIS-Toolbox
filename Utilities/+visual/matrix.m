
function [h, info] = matrix(data, opt)

arguments
    data (:, :) double

    opt.Marker (1, 1) char = 's'
    opt.VarySize (1, 1) logical = false
    opt.VaryColor (1, 1) logical = true
    opt.MaxColor (1, :) double = -1
    opt.MinColor (1, :) double = [0.9, 0.9, 0.9]
    opt.MaxSize (1, 1) double = 60
    opt.MinSize (1, 1) double = 5
    opt.MaxValue = @auto
    opt.MinValue = @auto
    opt.XTickLabels = @auto
    opt.YTickLabels = @auto
    opt.Test = []
    opt.AxesHandle = @axes
end

numRows = size(data, 1);
numColumns = size(data, 2);

value = reshape(data, [], 1);
[rows, columns] = ind2sub([numRows, numColumns], 1:numel(data));

if ~isempty(opt.Test)
    inxPass = opt.Test(value);
    value(~inxPass) = [];
    rows(~inxPass) = [];
    columns(~inxPass) = [];
end


if isequal(opt.MaxValue, @auto)
    opt.MaxValue = max(value);
end

if isequal(opt.MinValue, @auto)
    opt.MinValue = min(value);
end

if isscalar(opt.MaxColor)
    if opt.MaxColor>=0
        opt.MaxColor = repmat(opt.MaxColor, 1, 3);
    else
        colorOrder = get(0, "defaultAxesColorOrder");
        opt.MaxColor = 0.75 * colorOrder(mod(-opt.MaxColor, size(colorOrder, 1)), :);
    end
end

if isscalar(opt.MinColor)
    opt.MinColor = repmat(opt.MinColor, 1, 3);
end

axesHandle = opt.AxesHandle;
if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle();
end

set(axesHandle, "nextPlot", "add");
h = gobjects(1, numel(rows));
for i = 1 : numel(rows)
    z = (value(i) - opt.MinValue)/(opt.MaxValue - opt.MinValue);
    if opt.VaryColor
        color = (z * opt.MaxColor) + ((1 - z) * opt.MinColor);
    else
        color = opt.MaxColor;
    end
    if opt.VarySize
        markerSize = opt.MinSize + sqrt(z)*(opt.MaxSize - opt.MinSize);
    else
        markerSize = opt.MaxSize;
    end
    x = columns(i);
    y = numRows - rows(i) + 1;
    h(i) = plot( ...
        x, y ...
        , "lineStyle", "none" ...
        , "marker", opt.Marker ...
        , "markerSize", markerSize ...
        , "markerEdgeColor", color ...
        , "markerFaceColor", color ...
    );
end
set(axesHandle, "nextPlot", "replace");

if isequal(opt.XTickLabels, @auto)
    opt.XTickLabels = 1 : numColumns;
end

if isequal(opt.YTickLabels, @auto)
    opt.YTickLabels = numRows : -1 : 1;
end

set( ...
    axesHandle ...
    , "fontWeight", "bold" ...
    , "box", "on" ...
    , "xGrid", "off" ...
    , "yGrid", "off" ...
    , "xLim", [0, numColumns+1] ...
    , "yLim", [0, numRows+1] ...
    , "xTick", 1:numColumns ...
    , "yTick", 1:numRows ...
    , "xTickLabels", opt.XTickLabels ...
    , "yTickLabels", opt.YTickLabels ...
);

info = struct();
info.AxesHandle = axesHandle;

end%

