% Type `web Series/convert.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = convert(this, newFreq, varargin)

if isempty(this)
    return
end

if ~isempty(varargin) && isnumeric(varargin{1})
    range = double(varargin{1});
    varargin(1) = [ ];
else
    range = Inf;
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('Series.convert');
    addRequired(pp, 'InputSeries', @(x) isa(x, 'Series'));
    addRequired(pp, 'NewFreq', @Frequency.validateProperFrequency);

    addParameter(pp, {'ConversionMonth', 'StandinMonth'}, 1, @iris.Configuration.validateConversionMonth);
    addParameter(pp, {'RemoveMissing', 'RemoveNaN', 'IgnoreNaN', 'OmitNaN'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, "RemoveWeekends", false, @validate.logicalScalar);
    addParameter(pp, 'Missing', [], @(x) isempty(x) || validate.anyString(x, ["previous", "next"]) || validate.numericScalar(x));
    addParameter(pp, {'Method', 'Function'}, [], @(x) isempty(x) || isa(x, 'function_handle') || validate.stringScalar(x) || isnumeric(x));
    addParameter(pp, 'Position', 'center', @(x) validate.stringScalar(x) && startsWith(x, ["s", "b", "f", "c", "m", "e", "l"], "IgnoreCase", true));
    addParameter(pp, 'Select', Inf, @(x) isnumeric(x));
end
%)
opt = parse(pp, this, newFreq, varargin{:});

% Make sure newFreq is a Frequency object
if ~isa(newFreq, 'Frequency')
    [~, newFreq] = Frequency.validateProperFrequency(newFreq);
end



if isnan(this.Start) || isempty(this.Data)
    return
end

if isempty(range)
    this = this.empty(this);
    return
end

oldFreq = dater.getFrequency(this.Start);

if oldFreq==0 || newFreq==0
    throw( exception.Base('Series:CannotConvertIntegerFreq', 'error') )
end

if oldFreq==newFreq
    % Pass
    conversionFunc = [];
elseif oldFreq>newFreq
    % Aggregation
    conversionFunc = @local_aggregate;
else
    if validate.stringScalar(opt.Method) && startsWith(opt.Method, ["quadSum", "quadAvg", "quadMean"], "ignoreCase", true)
        % Sum- or average-matching interpolation
        conversionFunc = @local_interpolateQuadraticMatch;
    else
        % Non-matching interpolation
        conversionFunc = @local_interpolate;
    end
end

this = local_preprocessMissing(this, opt);

if ~isempty(conversionFunc)
    [oldStart, oldEnd] = resolveRange(this, range);
    [newData, newStart] = conversionFunc(this, oldStart, oldEnd, oldFreq, newFreq, opt);
    this = fill(this, newData, newStart, this.Comment, this.UserData);
end

if newFreq==Frequency.DAILY && opt.RemoveWeekends
    this = removeWeekends(this);
end

end%

%
% Local functions
%

function this = local_preprocessMissing(this, opt)
    %(
    if ~isempty(opt.Missing)
        this = fillMissing(this, Inf, opt.Missing);
    end
    %)
end%


function [newData, newStart] = local_aggregate(this, oldStart, oldEnd, oldFreq, newFreq, opt)
    %(
    %  
    % Handle Method=[], "first", "last", "random", in char, string
    % or function_handle
    %
    opt.Method = local_resolveSpecialAggregationMethods(opt.Method);


    %
    % Stretch the original range from the beginning of first year until the end
    % of last year; then convert the old dates to a vector of new dates of the
    % same size
    %
    if oldFreq==Frequency.DAILY
        [oldStartYear, ~, ~] = datevec(oldStart);
        [oldEndYear, ~, ~] = datevec(oldEnd);
        oldStart = dater.dd(oldStartYear, 1, 1);
        oldEnd = dater.dd(oldEndYear, 12, "end");
        oldDates = dater.colon(oldStart, oldEnd);
        if newFreq==Frequency.WEEKLY
            newDates = dater.day2ww(oldDates);
        else
            [newYears, newMonths] = datevec(oldDates);
            newDates = dater.datecode(newFreq, newYears, ceil(newFreq*newMonths/12));
        end
    else
        oldStartYear = dat2ypf(oldStart);
        oldEndYear = dat2ypf(oldEnd);
        oldStart = dater.datecode(oldFreq, oldStartYear, 1);
        oldEnd = dater.datecode(oldFreq, oldEndYear, "end");
        oldDates = dater.colon(oldStart, oldEnd);
        newDates = dater.convert(oldDates, newFreq, "ConversionMonth", opt.ConversionMonth);
    end

    oldData = getDataFromTo(this, oldStart, oldEnd);

    if oldFreq==Frequency.DAILY && opt.RemoveWeekends
        inxWeekend = dater.isWeekend(oldDates);
        newDates(inxWeekend) = [];
        oldData(inxWeekend, :) = [];
    end


    oldSize = size(oldData);
    oldData = oldData(:, :);
    numColumns = size(oldData, 2);
    newDatesSerial = dater.getSerial(newDates);
    newStartSerial = newDatesSerial(1);
    newEndSerial = newDatesSerial(end);
    numNewPeriods = newEndSerial - newStartSerial + 1;

    %
    % Apply the aggregation function period by period, column by column
    %
    newData = nan(0, numColumns);
    missingTest = this.MissingTest;
    for newSerial = newStartSerial : newEndSerial
        inxRows = newSerial==newDatesSerial;
        newAdd = nan(1, numColumns);
        if any(inxRows)
            oldAdd = oldData(inxRows, :);
            for col = 1 : numColumns
                method__ = opt.Method;
                if isnumeric(method__)
                    method__ = reshape(method__, 1, [ ]);
                end

                col__ = oldAdd(:, col);

                if opt.RemoveMissing
                    inxToKeep = ~missingTest(col__);
                    col__ = col__(inxToKeep);
                    if isnumeric(method__) && ~isempty(method__)
                        method__ = method__(inxToKeep);
                    end
                end

                if ~isequal(opt.Select, Inf)
                    try
                        col__ = col__(opt.Select);
                        if isnumeric(method__) && ~isempty(method__)
                            method__ = method__(opt.Select);
                        end
                    catch
                        col__ = double.empty(0, 1);
                        method__ = double.empty(1, 0);
                    end
                end

                if isempty(col__) 
                    continue
                end

                if isempty(method__)
                    newAdd(1, col) = col__;
                elseif isnumeric(method__)
                    try %#ok<TRYNC>
                        newAdd(1, col) = method__*col__;
                    end
                elseif isa(method__, 'function_handle') || ischar(method__) || isstring(method__)
                    try
                        newAdd(1, col) = feval(method__, col__, 1);
                    catch
                        newAdd(1, col) = feval(method__, col__);
                    end
                end
            end
        end
        newData = [newData; newAdd]; %#ok<AGROW>
    end

    if length(oldSize)>2
        newSize = oldSize;
        newSize(1) = numNewPeriods;
        newData = reshape(newData, newSize);
    end
    newStart = dater.fromSerial(newFreq, newStartSerial);
    %)
end%


function method = local_resolveSpecialAggregationMethods(method)
    %(

    if isempty(method)
        method = @mean;
        return
    end

    charMethod = char(method); % [^1]   
    % [^1]: Convert to char; this works both for char, string and function_handle

    if startsWith(charMethod, "last", "ignoreCase", true)
        method = "last";
    elseif startsWith(charMethod, "first", "ignoreCase", true)
        method = "first";
    elseif startsWith(charMethod, "random", "ignoreCase", true)
        method = "random";
    elseif startsWith(charMethod, "count", "ignoreCase", true)
        method = "count";
    end
    %)
end%


function [newData, newStart] = local_interpolate(this, oldStart, oldEnd, oldFreq, newFreq, opt)
    %(
    if isempty(opt.Method)
        opt.Method = "pchip";
    elseif startsWith(opt.Method, "writeToBeginning", "ignoreCase", true)
        opt.Method = "first";
    elseif startsWith(opt.Method, "writeToEnd", "ignoreCase", true)
        opt.Method = "last";
    end

    [oldStartYear, oldStartPer] = dat2ypf(oldStart);
    [oldEndYear, oldEndPer] = dat2ypf(oldEnd);

    if newFreq==Frequency.WEEKLY
        oldStartMonth = per2month(oldStartPer, oldFreq, 'first');
        oldEndMonth = per2month(oldEndPer, oldFreq, 'last');
        oldStartDay = datenum(oldStartYear, oldStartMonth, 1);
        oldEndDay = datenum(oldEndYear, oldEndMonth, eomday(oldEndYear, oldEndMonth));
        newStart = dater.day2ww(oldStartDay);
        newEnd = dater.day2ww(oldEndDay);
        % Cut off the very first and very last week; it helps handle some weird
        % cases
        % Disabled until we describe the weird cases
        % newStart = newStart + 1;
        % newEnd = newEnd - 1;
    elseif newFreq==Frequency.DAILY
        if oldFreq==Frequency.WEEKLY
            newStart = convert(oldStart, Frequency.DAILY) - 3;
            newEnd = convert(oldEnd, Frequency.DAILY) + 3;
        else
            startMonth = per2month(oldStartPer, oldFreq, 'first');
            endMonth = per2month(oldEndPer, oldFreq, 'last');
            newStart = dater.dd(oldStartYear, startMonth, 1);
            newEnd = dater.dd(oldEndYear, endMonth, eomday(oldEndYear, endMonth));
        end
    else
        newStartYear = oldStartYear;
        newEndYear = oldEndYear;
        % Find the earliest freq2 period contained (at least partially) in freq1
        % start period.
        newStartPer = 1 + floor((oldStartPer-1)*newFreq/oldFreq);
        % Find the latest freq2 period contained (at least partially) in freq1 end
        % period.
        newEndPer = ceil((oldEndPer)*newFreq/oldFreq);
        newStart = dater.datecode(newFreq, newStartYear, newStartPer);
        newEnd = dater.datecode(newFreq, newEndYear, newEndPer);
    end

    oldData = getDataFromTo(this, oldStart, oldEnd);
    oldSize = size(oldData);
    if startsWith(opt.Method, ["flat", "first", "last"], "ignoreCase", true)
        newData = here_flat( );
    else
        newData = here_interpolate( );
    end

    return

        function newData = here_interpolate( )
            oldData = oldData(:, :);
            numNewPeriods = floor(newEnd) - floor(newStart) + 1;
            oldGrid = dat2dec(oldStart:oldEnd, opt.Position);
            newGrid = dat2dec(newStart:newEnd, opt.Position);
            newData = interp1(oldGrid, oldData, newGrid, opt.Method, "extrap");
            if size(newData, 1)==1 && size(newData, 2)==numNewPeriods
                newData = newData(:);
            else
                newData = reshape(newData, [size(newData, 1), oldSize(2:end)]);
            end
        end%


        function newData = here_flat( )
            newRange = dater.colon(newStart, newEnd);
            oldRange = dater.colon(oldStart, oldEnd);
            newConverted = convert(newRange, oldFreq);
            newSize = oldSize;
            newSize(1) = numel(newRange);
            newData = nan(newSize);
            oldRange100 = round(100*oldRange);
            newConverted100 = round(100*newConverted);
            if startsWith(opt.Method, "flat", "ignoreCase", true)
                testPeriods = true(size(newConverted));
            else
                [~, newPeriods] = dat2ypf(newRange);
                if startsWith(opt.Method, "last", "ignoreCase", true)
                    testPeriods = newPeriods==newFreq;
                elseif startsWith(opt.Method, "first", "ignoreCase", true)
                    testPeriods = newPeriods==1;
                end
            end
            for i = 1 : numel(oldRange)
                inx = oldRange100(i)==newConverted100 & testPeriods;
                if any(inx)
                    newData(inx, :) = repmat(oldData(i, :), nnz(inx), 1);
                end
            end
        end%
    %)
end%


function [newData, newStart] = local_interpolateQuadraticMatch(this, oldStart, oldEnd, oldFreq, newFreq, opt)
    %(
    numWithin = newFreq/oldFreq;
    if numWithin~=round(numWithin)
        utils.error('Series:convert', ...
            ['Source and target frequencies are incompatible ', ...
            'in ''%s'' interpolation.'], ...
            opt.Method);
    end

    oldData = getDataFromTo(this, oldStart, oldEnd);
    oldSize = size(oldData);
    oldData = oldData(:, :);

    [oldStartYear, oldStartPer] = dat2ypf(oldStart);
    [oldEndYear, oldEndPer] = dat2ypf(oldEnd);

    newStartYear = oldStartYear;
    newEndYear = oldEndYear;
    % Find the earliest freq2 period contained (at least partially) in freq1
    % start period
    newStartPer = 1 + floor((oldStartPer-1)*newFreq/oldFreq);
    % Find the latest freq2 period contained (at least partially) in freq1 end
    % period
    newStart = dater.datecode(newFreq, newStartYear, newStartPer);

    [newData, flag] = local_implementQuadraticMatch(oldData, numWithin);
    if ~flag
        exception.warning([
            "Series:CannotInterpolateInsampleNaNs"
            "Cannot calculate the ""%s"" interpolation the time series "
            "with in-sample missing observations. "
        ], opt.Method);
    end
    if contains(lower(opt.Method), "sum")
        newData = newData / numWithin;
    end
    newData = reshape(newData, [size(newData, 1), oldSize(2:end)]);
    %)
end% 


function [y2, flag] = local_implementQuadraticMatch(y1, numWithin)
    %(
    [numPeriods, ny] = size(y1);
    y2 = nan(numPeriods*numWithin, ny);
%     t1 = (1 : numWithin)';
%     t2 = (numWithin+1 : 2*numWithin)';
%     t3 = (2*numWithin+1 : 3*numWithin)';
% 
%     M = [
%         numWithin, sum(t1), sum(t1.^2)
%         numWithin, sum(t2), sum(t2.^2)
%         numWithin, sum(t3), sum(t3.^2)
%     ];

    T = mean(1:numWithin);
    Tminus1 = T - numWithin;
    Tplus1 = T + numWithin;
    Tminus2 = T - 2*numWithin;
    Tplus2 = T + 2*numWithin;

    A = [
        Tminus1 .^ (0:2)
        1, T, mean((1:numWithin).^2)
        Tplus1 .^ (0:2)
    ];

    Afirst = [
        1, T, mean((1:numWithin).^2)
        Tplus1 .^ (0:2)
        Tplus2 .^ (0:2)
    ];

    Alast = [
        Tminus2 .^ (0:2)
        Tminus1 .^ (0:2)
        1, T, mean((1:numWithin).^2)
    ];

    a = (1:numWithin)' .^ (0:2);

    addNa = nan(3, 1);
    flag = true;

    for i = 1 : ny
        % y1__ = y1(:, i);
        % [iSample, flagi] = getsample(y1__');
        % flag = flag && flagi;
        % if ~any(iSample)
            % continue
        % end
        % y1__ = y1__(iSample);
        % iNObs = numel(y1__);

        yy = [ y1(1:end-2, i), y1(2:end-1, i), y1(3:end, i) ];
        yy = [ addNa, transpose(yy), addNa ];
        inxNa = all(isnan(yy), 1);

        % b = nan(3, numPeriods);
        % b(:, ~inxNa) = M \ yy(:, ~inxNa);
        % y2__ = nan(numWithin, numPeriods);

        c = nan(3, numPeriods);
        c(:, ~inxNa) = A \ yy(:, ~inxNa);
        c(:, 1) = Afirst \ y1(1:3, i);
        c(:, end) = Alast \ y1(end-2:end, i);

        % for t = 2 : numPeriods-1
        %     y2__(:, t) = b(1, t)*ones(numWithin, 1) + b(2, t)*t2 + b(3, t)*t2.^2;
        % end

        % y2__(:, 1) = b(1, 2) + b(2, 2)*t1 + b(3, 2)*t1.^2;
        % y2__(:, end) = b(1, end-1) + b(2, end-1)*t3 + b(3, end-1)*t3.^2;

        y2(:, i) = reshape(a * c, [], 1);
    end
    %)
end%


function data = first(data, varargin)
    data = data(1, :);
end%


function data = last(data, varargin)
    data = data(end, :);
end%


function data = count(data, varargin)
    data = nnz(~isnan(data));
end%


function data = random(data, varargin)
    numRows = size(data, 1);
    if numRows==1
        return
    else
        pos = randi(numRows);
        data = data(pos, :);
    end
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/convertUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test Business Daily

x1 = Series(dd(2020,1,1):dd(2020,3,"end"), @rand);
x2 = removeWeekends(x1);

y1 = convert(x1, Frequency.MONTHLY);
y2 = convert(x2, Frequency.MONTHLY);
y3 = convert(x1, Frequency.MONTHLY, "removeWeekends", true);
y4 = convert(x2, Frequency.MONTHLY, "method", @nanmean);
y5 = convert(x2, Frequency.MONTHLY, "missing", -100);
y6 = convert(x2, Frequency.MONTHLY, "removeMissing", true);

assertEqual(testCase, size(y1.Data, 1), 3);
assertTrue(testCase, isempty(y2));
assertEqual(testCase, size(y3.Data, 1), 3);
assertNotEqual(testCase, y1.Data, y3.Data);
assertEqual(testCase, y3.Data, y4.Data, "absTol", 1e-12);
assertLessThan(testCase, y5.Data, 0);
assertEqual(testCase, y3.Data, y6.Data, "absTol", 1e-12);

##### SOURCE END #####
%}
