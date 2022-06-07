
% >=R2019b
%{
function [lineHandle, errorHandle, obj] = errorbar(axesHandle, time, data, plotSpec, opt)


arguments
    axesHandle (1, 1) {mustBeA(axesHandle, "handle")}
    time 
    data (:, :) double
    plotSpec (1, :) cell = cell.empty(1, 0)

    opt.ErrorBarSettings (1, :) cell = cell.empty(1, 0)
    opt.PlotSettings (1, :) cell = cell.empty(1, 0)
    opt.LinkColor = true
end
%}
% >=R2019b


% <=R2019a
%(
function [lineHandle, errorHandle, obj] = errorbar(axesHandle, time, data, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addOptional(ip, 'plotSpec', cell.empty(1, 0), @iscell);
    addParameter(ip, 'ErrorBarSettings', cell.empty(1, 0));
    addParameter(ip, 'PlotSettings', cell.empty(1, 0));
    addParameter(ip, 'LinkColor', true);
end
ip.parse(axesHandle, varargin{:});
plotSpec = ip.Results.plotSpec;
opt = ip.Results;
%)
% <=R2019a


DEFAULT_ERRORBAR_SETTINGS = {
    "marker"; "+"
    "markerSize"; 9
    "LineWidth"; 1.5
    "lineStyle"; ":"
};

isHold = ishold(axesHandle);
hold(axesHandle, "on");

time = reshape(time, [], 1);
lineHandle = plot(axesHandle, time, data(:, 1), opt.PlotSettings{:});

numPeriods = size(data, 1);
negativeError = data(:, 2);
positiveError = data(:, end);
errorYData = [data(:, 1)-negativeError, data(:, 1)+positiveError, nan(numPeriods, 1)];
errorYData = reshape(transpose(errorYData), [], 1);

errorXData = [time, time, time];
errorXData = reshape(transpose(errorXData), [], 1);

colorIndex = get(axesHandle, "colorOrderIndex");

errorHandle = plot( ...
    axesHandle, errorXData, errorYData ...
    , DEFAULT_ERRORBAR_SETTINGS{:} ...
    , opt.ErrorBarSettings{:} ...
);

set(axesHandle, "colorOrderIndex", colorIndex);

if opt.LinkColor
    obj = linkprop([lineHandle, errorHandle], "color");
    setappdata(axesHandle, 'IRIS_ErrorBarLinkPropObject', obj);
end

if ~isHold
    hold(axesHandle, "off");
end

end%

