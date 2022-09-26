
% >=R2019b
%{
function ascii(x, opt)

arguments
    x Series
    opt.Column (1, 1) = 1
    opt.Range double = Inf
    opt.Type (1, 1) string {mustBeMember(opt.Type, ["scatter", "bar"])} = "bar"
end
%}
% >=R2019b


% <=R2019a
%(
function ascii(x, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "Column", 1, @(x) isequal(x, "end") || (isnumeric(x) && isscalar(x)));
    addParameter(ip, "Range", Inf, @validate.range);
    addParameter(ip, "Type", "bar", @(x) ismember(x, ["scatter", "bar"]));
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


    LINE = char(hex2dec('02595'));
    DOT = char(hex2dec('25cf'));
    BAR = char(hex2dec('2588'));

    numPer = size(x.Data, 1);
    blankColumn = repmat(' ', numPer, 1);
    lineColumn = repmat(LINE, numPer, 1);

    if isequal(opt.Range, Inf)
        range = getRange(x);
    else
        range = opt.Range;
    end
    range = double(range);
    range = dater.colon(range(1), range(end));

    datesChar = reshape(dater.toDefaultString(range), [], 1);
    datesChar = [repmat('    ', numPer, 1), strjust(char(datesChar)), repmat(':', numPer, 1)];

    data = getDataFromTo(x, range);
    if isnumeric(opt.Column) && ~isinf(opt.Column)
        data = x.Data(:, opt.Column);
    else
        data = x.Data(:, end);
    end
    dataChar = char(compose("%12g", data));
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

    textual.looseLine();
    disp([datesChar, dataChar, plotChar]);
    textual.looseLine();

end%

