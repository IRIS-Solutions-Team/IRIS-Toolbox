function outputHandles = band(axesHandle, midLineHandle, midData, xCoor, lowerData, upperData, options)

BACKGROUND_LEVEL = -1;

xCoor = reshape(xCoor, [], 1);
lowerData = lowerData(:, :);
upperData = upperData(:, :);
numMidLines = size(midData, 2);
numLowerLines = size(lowerData, 2);
numUpperLines = size(upperData, 2);
numBands = max([numMidLines, numLowerLines, numUpperLines]);
numWhites = numel(options.White);

nextPlot = get(axesHandle, 'nextPlot');

outputHandles = [ ];

% Base color(s) derived from center line(s).
col = get(midLineHandle, 'color');
if ~iscell(col)
    col = { col };
end

for i = 1 : numBands
    if i <= numWhites
        white = options.White(i);
    elseif i > numMidLines
        white = white.^2;
    end

    % Retrieve current set of data.
    iCData = midData(:, min(i, end));
    iLData = lowerData(:, min(i, end));
    if options.Relative && all( iLData(:) >=0 )
        iLData = -iLData;
    end
    iHData = upperData(:, min(i, end));

    % Create x- and y-data for the patch function.
    xData = [ xCoor; flipud(xCoor) ];
    yData = [ iLData; flipud(iHData) ];
    if options.Relative
        yData = yData + [ iCData; flipud(iCData) ];
    end

    % Remove data points where either xData or yData is NaN.
    % ixNa = isnan(yData);
    % if all(ixNa)
        % continue
    % end
    % xData = xData(~ixNa);
    % yData = yData(~ixNa);

    % Draw patch object, mix its face color.
    set(axesHandle, 'nextPlot', 'add');
    p = patch(xData, yData, 'white');
    set(axesHandle, 'nextPlot', nextPlot);

    faceCol = col{min(i, end)}; % white*[1, 1, 1] + (1-white)*col{min(i, end)};
    set(  ...
        p ...
        , 'faceColor', faceCol ...
        , 'faceAlpha', 1-white ...
        , 'edgeColor', 'white' ...
        , 'lineStyle', '-' ...
        , 'tag', 'band' ...
    );

    % Stack handles bottom up (same order as in axes children). Wider bands
    % need to be plotted before narrower bands.
    outputHandles = [p; outputHandles]; %#ok<AGROW>
end

if isempty(outputHandles)
    return
end

for h = reshape(outputHandles, 1, [])
    setappdata(h, 'IRIS_BackgroundLevel', BACKGROUND_LEVEL);
end
visual.backend.moveToBackground(outputHandles);


if options.ExcludeFromLegend
    visual.excludeFromLegend(outputHandles);
end

end%

