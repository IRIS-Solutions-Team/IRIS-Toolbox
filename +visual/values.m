function handlesText = values(handles, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('visual.values');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('Handles', @(x) all(isgraphics(x)));
    inputParser.addParameter('Format', '%.1f', @(x) (ischar(x) || (isstring(x) && isscalar(x))));
    inputParser.addParameter('FontSizeMultiplier', 0.9, @(x) isnumeric(x) && isscalar(x) && x>0);
    inputParser.addParameter('Placement', 'Outside', @(x) any(strcmpi(x, {'Outside', 'Inside'})));
end
inputParser.parse(handles, varargin{:});
opt = inputParser.Options;
unmatched = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

handlesText = gobjects(0, 1);
numHandles = numel(handles);
for i = 1 : numHandles
    h = handles(i);
    parent = get(h, 'Parent');
    baseFontSize = get(parent, 'FontSize');
    fontSize = baseFontSize * opt.FontSizeMultiplier;
    xData = h.XData;
    try
        if ~isempty(h.XOffset)
            xData = xData + h.XOffset;
        end
    end
    yData = h.YData;
    try
        if ~isempty(h.YOffset)
            yData = yData + h.YOffset;
        end
    end

    if strcmpi(opt.Placement, 'Outside')
        placePositive = 'Bottom';
        placeNegative = 'Top';
    else
        placePositive = 'Top';
        placeNegative = 'Bottom';
    end

    indexPositive = yData>=0;
    handlesText = [ 
        printValues( ...
            parent, ...
            xData(indexPositive), yData(indexPositive), ...
            placePositive, fontSize, opt, unmatched{:} ...
        )
        printValues( ...
            parent, ...
            xData(~indexPositive), yData(~indexPositive), ...
            placeNegative, fontSize, opt, unmatched{:} ...
        )
    ];
end

end%


function handlesText = printValues(handleAxes, xData, yData, vertical, fontSize, opt, varargin)
    if isempty(xData) || isempty(yData)
        handlesText = gobjects(0, 1);
        return
    end
    stringYData = arrayfun(@(x) sprintf(opt.Format, x), yData, 'UniformOutput', false);
    handlesText = text( ...
        handleAxes, ...
        xData, yData, stringYData, ...
        'FontSize', fontSize, ...
        'VerticalAlignment', vertical, ...
        'HorizontalAlignment', 'Center', ...
        varargin{:} ...
    );
end%

