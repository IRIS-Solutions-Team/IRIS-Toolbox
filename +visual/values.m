function textHandles = values(handles, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('visual.values');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('Handles', @(x) all(isgraphics(x)));
    inputParser.addParameter('Every', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x~=0);
    inputParser.addParameter('Format', '%.1f', @(x) (ischar(x) || (isstring(x) && isscalar(x))));
    inputParser.addParameter('FontSizeMultiplier', 0.9, @(x) isnumeric(x) && isscalar(x) && x>0);
    inputParser.addParameter('Placement', 'Outside', @(x) any(strcmpi(x, {'Outside', 'Inside'})));
end
inputParser.parse(handles, varargin{:});
opt = inputParser.Options;
unmatched = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

textHandles = gobjects(0, 1);
numOfHandles = numel(handles);
for i = 1 : numOfHandles
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

    indexOfPositive = yData>=0;
    textHandles = [ 
        printValues( ...
            parent, ...
            xData(indexOfPositive), yData(indexOfPositive), ...
            placePositive, fontSize, opt, unmatched{:} ...
        )
        printValues( ...
            parent, ...
            xData(~indexOfPositive), yData(~indexOfPositive), ...
            placeNegative, fontSize, opt, unmatched{:} ...
        )
    ];
end

end%


function textHandles = printValues(handleAxes, xData, yData, vertical, fontSize, opt, varargin)
    if isempty(xData) || isempty(yData)
        textHandles = gobjects(0, 1);
        return
    end
    if opt.Every~=1 && opt.Every~=-1
        if opt.Every>1
            xData = xData(1:opt.Every:end);
            yData = yData(1:opt.Every:end);
        else
            xData = xData(end:opt.Every:1);
            yData = yData(end:opt.Every:1);
        end
        if isempty(xData) || isempty(yData)
            return
        end
    end
    stringYData = arrayfun(@(x) sprintf(opt.Format, x), yData, 'UniformOutput', false);
    textHandles = text( ...
        handleAxes, ...
        xData, yData, stringYData, ...
        'FontSize', fontSize, ...
        'VerticalAlignment', vertical, ...
        'HorizontalAlignment', 'Center', ...
        varargin{:} ...
    );
end%

