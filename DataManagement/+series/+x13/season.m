function varargout = season(data, startDate, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('series.x13.series');
    pp.KeepUnmatched = true;
    addRequired(pp, 'data', @(x) isnumeric(x));
    addRequired(pp, 'startDate', @(x) isscalar(x) && DateWrapper.validateProperDateInput(x));

    % General options
    addParameter(pp, 'Display', false, @validate.logicalScalar);
    addParameter(pp, 'Output', "d11", @(x) isstring(x) || ischar(x) || iscellstr(x));
    addParameter(pp, 'ExcludeEmpty', ["automdl"], @isstring);

    % Series specs
    addParameter(pp, 'Series.Precision', 5, @(x) validate.roundScalar(x, 1, 5));
    addParameter(pp, 'Series.Decimals', 5, @(x) validate.roundScalar(x, 1, 5));
    
    % X11 specs
    addParameter(pp, 'X11.Mode', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'Add', 'Mult', 'PseudoAdd', 'LogAdd'));
    addParameter(pp, 'X11.Save', string.empty(1, 0), @isstring);
    addParameter(pp, 'X11.SeasonalMA', @default, @(x) isstring(x) || ischar(x));
    addParameter(pp, 'X11.TrendMA', @default, @(x) validate.roundScalar(x, 3, 101) && mod(x, 2)==1);
    addParameter(pp, 'X11.SigmaLim', @default, @(x) isequal(x, @default) || (isnumeric(x) && numel(x)==2 && all(x>0) && x(2)>x(1)));
    addParameter(pp, 'X11.AppendFcst', @default, @(x) isequal(x, @default) || validate.logicalScalar(x));
    addParameter(pp, 'X11.AppendBcst', @default, @(x) isequal(x, @default) || validate.logicalScalar(x));
end
opt = parse(pp, data, startDate, varargin{:});
%)

%-------------------------------------------------------------------------------

outputTables = hereResolveOutputTables( );
numOutputTables = numel(outputTables);

sizeData = size(data);
numColumns = prod(sizeData(2:end));
outputData = repmat({nan(sizeData)}, 1, numOutputTables);
outputInfo = [ ];
inxMissingTable = false(1, numOutputTables);
inxError = false(1, numColumns);
for i = 1 : numColumns
    opt__ = opt;
    [data__, startDate__, first, last] = locallyResolveData(data(:, i), startDate, opt__);
    if isempty(data__)
        continue
    end

    [opt__, flipSign] = locallyResolveMode(data__, opt__);
    data__ = flipSign*data__;

    code = string.empty(0, 1);
    code = [code; series.x13.series(data__, startDate__, opt__)];
    listSpecs = ["x11"];
    for n = listSpecs
        code = [code; series.x13.compileSpecs(n, opt__)];
    end
    code = join(code, string(newline()));

    outputData__ = cell(1, numOutputTables);
    [info__, outputData__{1:end}] = series.x13.run(code, outputTables, opt__);
    info__.Mode = opt__.X11_Mode;

    for j = 1 : numOutputTables
        x__ = outputData__{j};
        if ~isempty(x__)
            outputData{j}(first:last, i) = flipSign*x__;
        else
            inxMissingTable(j) = true;
        end
    end
    inxError(i) = contains(info__.Message, "Check error file", 'IgnoreCase', true);
    outputInfo = [outputInfo, info__];
end

varargout = [outputData, {outputInfo}];
disp(inxMissingTable)
disp(inxError)

return

    function outputTables = hereResolveOutputTables( )
        %(
        human = [
            "sf",  "d10"
            "sa",  "d11"
            "tc",  "d12"
            "irr", "d13"
        ];
        mapTables = struct( ...
            "d10", "X11" ...
            , "d11", "X11" ...
            , "d12", "X11" ...
            , "d13", "X11" ...
            , "mva", "Series" ...
        );
        outputTables = string(opt.Output);
        if isscalar(outputTables)
            outputTables = regexp(outputTables, "\w+", "match");
        end
        outputTables = reshape(lower(outputTables), 1, [ ]);
        for n = transpose(human)
            inx = outputTables==n(1);
            outputTables(inx) = n(2);
        end
        for n = outputTables
            opt.(mapTables.(n)+"_Save")(end+1) = n;
        end
        %)
    end%
end%


%
% Local Functions
%


function [first, last, flipSign, opt] = locallyResolveData(data, startDate, opt)
    %(
    inxNaN = ~isfinite(data);
    first = find(~inxNaN, 1, 'First');
    last = find(~inxNaN, 1, 'Last');
    flipSign = 1;
    if isempty(first) || isempty(last)
        data = [ ];
        startDate = [ ];
        return
    end
    data = data(first:last);
    startDate = DateWrapper.roundPlus(startDate, first-1);
    [startYear, startPeriod, freq] = dat2ypf(startDate);
    opt.Series_Start = string(startYear) + "." + string(startPeriod);
    opt.Series_Freq = string(freq); 
    if isequal(opt.X11_Mode, @auto)
        inxNaN = ~isfinite(data);
        if all(data(~inxNaN)>0)
            opt.X11_Mode = "mult";
        elseif all(data(~inxNaN)<0)
            opt.X11_Mode = "mult";
            flipSign = -1;
        else
            opt.X11_Mode = "add";
        end
    end
    %)
end%



%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=series.x13/seasonUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test Vanilla

data = randn(40, 1);
data = series.cumsumk(data, 4);

##### SOURCE END #####
%}
