
function ascii(x, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "Type", "scatter", @(x) ismember(x, ["scatter", "bar"]));
    addParameter(ip, "Column", 1, @(x) isequal(x, "end") || (isnumeric(x) && isscalar(x)));
end
parse(ip, varargin{:});
opt = ip.Results;


    LINE = char(hex2dec('02595'));
    DOT = char(hex2dec('25cf'));
    BAR = char(hex2dec('2588'));

    numPer = size(x.Data, 1);
    blankColumn = repmat(' ', numPer, 1);
    lineColumn = repmat(LINE, numPer, 1);

    datesChar = reshape(dater.toDefaultString(getRange(x)), [], 1);
    datesChar = [repmat('    ', numPer, 1), strjust(char(datesChar)), repmat(':', numPer, 1)];

    if isnumeric(opt.Column)
        data = x.Data(:, opt.Column);
    else
        data = x.Data(:, end);
    end
    dataChar = char(compose("%12g", x.Data(:, 1)));
    inxEmpty = all(dataChar==' ', 1);
    dataChar(:, inxEmpty) = '';
    dataChar = [blankColumn, dataChar, blankColumn];

    inx = ~isnan(data);
    maxData = max(data(inx));
    minData = min(data(inx));
    minPos = 1;
    maxPos = 50;
    if maxData>minData
        trans = round( minPos + (data - minData) ./ (maxData - minData) * (maxPos - minPos) );
    else
        trans = repmat(maxPos, numPer, 1);
    end
    plotChar = repmat(' ', numPer, maxPos - minPos + 1);

    for i = 1 : numPer
        switch opt.Type
            case "bar"
                plotChar(i, 1:trans(i)) = BAR;
            otherwise
                plotChar(i, trans(i)) = DOT;
        end
    end

    disp("");
    disp([datesChar, dataChar, plotChar]);
    disp("");

end%

