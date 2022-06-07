
% >=R2019b
%{
function [lineHandle, errorHandle, obj] = errorbar(time, data, opt)

arguments
    time 
    data (:, :) double

    opt.Relative (1, 1) logical = true
    opt.AxesHandle = @gca
    opt.ErrorBarSettings (1, :) cell = cell.empty(1, 0)
    opt.PlotSettings (1, :) cell = cell.empty(1, 0)
    opt.LinkColor = true
end
%}
% >=R2019b


% <=R2019a
%(
function [lineHandle, errorHandle, obj] = errorbar(time, data, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Relative', true);
    addParameter(ip, 'AxesHandle', @gca);
    addParameter(ip, 'ErrorBarSettings', cell.empty(1, 0));
    addParameter(ip, 'PlotSettings', cell.empty(1, 0));
    addParameter(ip, 'LinkColor', true);
end
ip.parse(varargin{:});
opt = ip.Results;
%)
% <=R2019a


DEFAULT_ERRORBAR_SETTINGS = {
    "marker"; "+"
    "markerSize"; 9
    "LineWidth"; 1.5
    "lineStyle"; ":"
};

axesHandle = opt.AxesHandle;
if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle();
end
isHold = ishold(axesHandle);
hold(axesHandle, "on");

time = reshape(time, [], 1);
lineHandle = plot(axesHandle, time, data(:, 1), opt.PlotSettings{:});

numPeriods = size(data, 1);
lower = data(:, 2);
upper = data(:, end);
if opt.Relative
    errorYData = [data(:, 1)-lower, data(:, 1)+upper, nan(numPeriods, 1)];
else
    errorYData = [lower, upper, nan(numPeriods, 1)];
end
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

