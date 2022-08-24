% barcon  Contribution bar chart for numeric data
%

function handlePositive = barcon(handleAxes, time, data, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('series.barcon');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('Axes', @(x) isscalar(x) && isgraphics(x, 'Axes'));
    inputParser.addRequired('Time', @(x) isnumeric(x) || isa(x, 'datetime'));
    inputParser.addRequired('Data', @isnumeric);
    inputParser.addParameter('ColorMap', lines( ), @(x) isnumeric(x) && ismatrix(x) && size(x, 2)==3);
    inputParser.addParameter('EvenlySpread', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
end
inputParser.parse(handleAxes, time, data, varargin{:});
opt = inputParser.Options;
unmatchedOptions = inputParser.UnmatchedInCell;

linesColorMap = lines( );
if isequal(opt.EvenlySpread, @auto)
    opt.EvenlySpread = ~isequal(opt.ColorMap, linesColorMap);
end

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
if isequal(opt.ColorMap, linesColorMap) && ~opt.EvenlySpread
    colorOrderIndex = get(handleAxes, 'ColorOrderIndex');
else
    colorOrderIndex = 1;
end

% Plot negative values
hold(handleAxes, 'on');
handleNegative = bar(handleAxes, time, negativeData, 'stack', unmatchedOptions{:});
set(handleAxes, 'ColorOrderIndex', colorOrderIndex);
if ~isHold
    hold(handleAxes, 'off');
end

positionsInColorMap = getPositionsInColorMap( );
for i = 1 : numData
    faceColor = opt.ColorMap(positionsInColorMap(i), :);
    set(handlePositive(i), 'FaceColor', faceColor);
end

linkedProperties = getLinkedProperties( );
linkProperties( );
visual.excludeFromLegend(handleNegative);

return


    function linkedProperties = getLinkedProperties( )
        linkedProperties = {
            'FaceColor'
            'EdgeColor'
            'FaceAlpha'
            'EdgeAlpha'
            'LineStyle'
            'LineWidth'
            'CData'
        };
        indexValid = true(size(linkedProperties));
        for i = 1 : numel(linkedProperties)
            try
                get(handlePositive, linkedProperties{i});
            catch
                indexValid(i) = false;
            end
        end
        linkedProperties = linkedProperties(indexValid);
    end%


    function positionsInColorMap = getPositionsInColorMap( )
        if opt.EvenlySpread
            positionsInColorMap = linspace(1, numColorMap, numData);
            positionsInColorMap = round(positionsInColorMap);
        else
            positionsInColorMap = 1 + mod((1:numData)-1, numColorMap);
        end
    end%


    function linkProperties( )
        for i = 1 : numData
            p = get(handlePositive(i), linkedProperties);
            set(handleNegative(i), linkedProperties, p);
            linkObject = linkprop([handlePositive(i), handleNegative(i)], linkedProperties);
            set(handlePositive(i), 'UserData', linkObject);
            set(handleNegative(i), 'UserData', linkObject);
        end
    end%
end%
