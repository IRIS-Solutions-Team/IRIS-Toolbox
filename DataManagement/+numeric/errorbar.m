function [handleLine, handleErrors, obj] = errorbar(handleAxes, time, data, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('numeric.errorbar');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('Axes', @(x) isscalar(x) && isgraphics(x, 'Axes'));
    inputParser.addRequired('Time', @(x) isnumeric(x) || isa(x, 'datetime'));
    inputParser.addRequired('Data', @(x) isnumeric(x) && ismatrix(x) && any(size(x, 2)==[2, 3]));
    inputParser.addParameter('ErrorBar', ...
                             cell.empty(1, 0), ...
                             @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))));
    inputParser.addParameter('LinkProp', {'Color'}, @(x) isempty(x) || iscellstr(x) || ischar(x) || isa(x, 'string'));
end
inputParser.parse(handleAxes, time, data, varargin{:});
opt = inputParser.Options;
unmatchedOptions = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

isHold = ishold(handleAxes);
hold(handleAxes, 'on');

time = time(:);
handleLine = plot(handleAxes, time, data(:, 1), unmatchedOptions{:});
numPeriods = size(data, 1);
negativeError = data(:, 2);
positiveError = data(:, end);
errorYData = [data(:, 1)-negativeError, data(:, 1)+positiveError, nan(numPeriods, 1)];
errorYData = errorYData';
errorYData = errorYData(:);
errorXData = [time, time, time];
errorXData = errorXData';
errorXData = errorXData(:);
index = get(handleAxes, 'ColorOrderIndex');
handleErrors = plot( ...
    handleAxes, errorXData, errorYData, ...
    'Marker', '+', 'MarkerSize', 9, 'LineWidth', 1.5, ... 0.70*get(handleLine, 'LineWidth'), ...
    'LineStyle', ':', ...
    'HandleVisibility', 'off', ...
    opt.ErrorBar{:} ...
);
set(handleAxes, 'ColorOrderIndex', index);

if ~isempty(opt.LinkProp)
    if ~iscellstr(opt.LinkProp)
        opt.LinkProp = cellstr(opt.LinkProp);
    end
    obj = linkprop([handleLine, handleErrors], opt.LinkProp);
    setappdata(handleAxes, 'IRIS_ErrorBarLinkPropObject', obj);
end

if ~isHold
    hold(handleAxes, 'off');
end

end%
