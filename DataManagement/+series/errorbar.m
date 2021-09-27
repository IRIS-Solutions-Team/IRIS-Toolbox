% >=R2019b
%{
function [lineHandle, errorHandle, obj] = errorbar(axesHandle, time, data, options)

arguments
    axesHandle (1, 1) {mustBeA(axesHandle, "handle")}
    time 
    data (:, :) double

    options.ErrorBarSettings (1, :) cell = cell.empty(1, 0)
    options.PlotSettings (1, :) cell = cell.empty(1, 0)
    options.LinkColor = true
end
%}
% >=R2019b

% <=R2019a
%(
function [lineHandle, errorHandle, obj] = errorbar(axesHandle, time, data, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('numeric.errorbar');

    pp.addRequired('Axes', @(x) isscalar(x) && isgraphics(x, 'Axes'));
    pp.addRequired('Time', @(x) isnumeric(x) || isa(x, 'datetime'));
    pp.addRequired('Data', @(x) isnumeric(x) && any(size(x, 2)==[2, 3]));

    pp.addParameter('ErrorBarSettings', cell.empty(1, 0), @iscell);
    pp.addParameter('PlotSettings', cell.empty(1, 0), @iscell);
    pp.addParameter('LinkColor', true);
end
options = pp.parse(axesHandle, time, data, varargin{:});
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
lineHandle = plot(axesHandle, time, data(:, 1), options.PlotSettings{:});

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
    , options.ErrorBarSettings{:} ...
);

set(axesHandle, "colorOrderIndex", colorIndex);

if options.LinkColor
    obj = linkprop([lineHandle, errorHandle], "color");
    setappdata(axesHandle, 'IRIS_ErrorBarLinkPropObject', obj);
end

if ~isHold
    hold(axesHandle, "off");
end

end%

