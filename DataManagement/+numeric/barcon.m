function handlePositive = barcon(handleAxes, time, data, varargin)
% barcon  Contribution bar chart for numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('numeric.barcon');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('Axes', @(x) isscalar(x) && isgraphics(x, 'Axes'));
    inputParser.addRequired('Time', @(x) isnumeric(x) || isa(x, 'datetime'));
    inputParser.addRequired('Data', @isnumeric);
    inputParser.addOptional('SpecString', cell.empty(1, 0), @(x) iscellstr(x)  && numel(x)<=1);
    inputParser.addParameter('ColorMap', lines( ), @(x) isnumeric(x) && ismatrix(x) && size(x, 2)==3);
    inputParser.addParameter('EvenlySpread', false, @(x) isequal(x, true) || isequal(x, false));
end
inputParser.parse(handleAxes, time, data, varargin{:});
opt = inputParser.Options;
unmatchedOptions = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

numColorMap = size(opt.ColorMap, 1);
data = data(:, :);
numData = size(data, 2);
data(data==0) = NaN;
positiveData = data;
negativeData = data;
positiveData(data<0) = NaN;
negativeData(data>0) = NaN;

isHold = ishold(handleAxes);

% Plot positive values
handlePositive = bar(handleAxes, time, positiveData, 'stack', unmatchedOptions{:});
colorOrderIndex = get(handleAxes, 'ColorOrderIndex');

% Plot negative values
hold(handleAxes, 'on');
handleNegative = bar(handleAxes, time, negativeData, 'stack', unmatchedOptions{:});
set(handleAxes, 'ColorOrderIndex', colorOrderIndex);

linkedProperties = {
    'FaceColor'
    'EdgeColor'
    'FaceAlpha'
    'EdgeAlpha'
    'LineStyle'
    'LineWidth'
    'CData'
};

if opt.EvenlySpread
    positionInColorMap = linspace(1, numColorMap, numData);
    positionInColorMap = round(positionInColorMap);
else
    positionInColorMap = 1 + mod((1:numData)-1, numColorMap);
end

for i = 1 : numData
    faceColor = opt.ColorMap(positionInColorMap(i), :);
    set(handlePositive(i), 'FaceColor', faceColor);
end

for i = 1 : numData
    p = get(handlePositive(i), linkedProperties);
    set(handleNegative(i), linkedProperties, p);
    linkObject = linkprop([handlePositive(i), handleNegative(i)], linkedProperties);
    set(handlePositive(i), 'UserData', linkObject);
    set(handleNegative(i), 'UserData', linkObject);
end

visual.excludeFromLegend(handleNegative);

end%
