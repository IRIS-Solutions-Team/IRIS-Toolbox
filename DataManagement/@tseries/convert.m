% Type `web Series/convert.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

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
    pp = extend.InputParser('TimeSubscriptable.convert');
    addRequired(pp, 'InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    addRequired(pp, 'NewFreq', @Frequency.validateProperFrequency);

    addParameter(pp, {'ConversionMonth', 'StandinMonth'}, 1, @(x) (isnumeric(x) && isscalar(x) && x==round(x)) || startsWith(x, "first", "ignoreCase", true) || startsWith(x, "last", "ignoreCase", true));
    addParameter(pp, {'RemoveNaN', 'IgnoreNaN', 'OmitNaN'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Missing', NaN, @(x) (ischar(x) && any(strcmpi(x, {'Last', 'Previous'}))) || validate.numericScalar(x));
    addParameter(pp, {'Method', 'Function'}, @default, @(x) isequal(x, @default) || isa(x, 'function_handle') || validate.stringScalar(x) || isnumeric(x));
    addParameter(pp, 'Position', 'center', @(x) validate.stringScalar(x) && startsWith(x, ["s", "b", "f", "c", "m", "e", "l"], "IgnoreCase", true));
    addParameter(pp, 'Select', Inf, @(x) isnumeric(x));
    addParameter(pp, "RemoveWeekends", false, @validate.logicalScalar);
end
%)
opt = parse(pp, this, newFreq, varargin{:});

% Make sure newFreq is a Frequency object
if ~isa(newFreq, 'Frequency')
    [~, newFreq] = Frequency.validateProperFrequency(newFreq);
end

%--------------------------------------------------------------------------

if isnan(this.Start) && isempty(this.Data)
    return
end

if isempty(range)
    this = this.empty(this);
    return
end

oldFreq = dater.getFrequency(this.Start);

if oldFreq==newFreq
    return
end

if oldFreq==0 || newFreq==0
    throw( exception.Base('Series:CannotConvertIntegerFreq', 'error') )
end

if oldFreq>newFreq
    % Aggregate
    conversionFunc = @locallyAggregate;
else
    % Interpolate matching sum or average
    if validate.stringScalar(opt.Method) && startsWith(opt.Method, ["quadSum", "quadAvg", "quadMean"], "ignoreCase", true)
        conversionFunc = @locallyInterpolateAndMatch;
    else
        % Built-in interp1
        conversionFunc = @locallyInterpolate;
    end
end

[oldStart, oldEnd] = resolveRange(this, range(1), range(end));
[newData, newStart] = conversionFunc(this, oldStart, oldEnd, oldFreq, newFreq, opt);

if newFreq==Frequency.DAILY && opt.RemoveWeekends
    range = round(newStart + (0 : size(newData, 1)-1));
    inxWeekend = dater.isWeekend(range);
    newData(inxWeekend, :) = NaN;
end
this = fill(this, newData, newStart, this.Comment, this.UserData);

end%


%
% Local functions
%


function [newData, newStart] = locallyAggregate(this, oldStart, oldEnd, oldFreq, newFreq, opt)
    charMethod = char(opt.Method);
    if startsWith(charMethod, "Default", "ignoreCase", true)
        opt.Method = @mean;
    elseif startsWith(charMethod, "Last", "ignoreCase", true)
        opt.Method = "last";
    elseif startsWith(charMethod, "First", "ignoreCase", true)
        opt.Method = "first";
    elseif startsWith(charMethod, "Random", "ignoreCase", true)
        opt.Method = "random";
    end

    % Stretch the original range from the beginning of first year until the end
    % of last year
    if oldFreq==Frequency.DAILY
        [oldStartYear, ~, ~] = datevec(oldStart);
        [oldEndYear, ~, ~] = datevec(oldEnd);
        oldStart = numeric.dd(oldStartYear, 1, 1);
        oldEnd = numeric.dd(oldEndYear, 12, 'end');
        if newFreq==52
            newDates = numeric.day2ww(oldStart:oldEnd);
        else
            [newYears, newMonths] = datevec(oldStart:oldEnd);
            newDates = numeric.datecode(newFreq, newYears, ceil(newFreq*newMonths/12));
        end
    else
        oldStartYear = dat2ypf(oldStart);
        oldEndYear = dat2ypf(oldEnd);
        oldStart = numeric.datecode(oldFreq, oldStartYear, 1);
        oldEnd = numeric.datecode(oldFreq, oldEndYear, 'end');
        newDates = numeric.convert( ...
            oldStart:oldEnd, newFreq, ...
            'ConversionMonth=', opt.ConversionMonth ...
        );
    end

    oldData = getDataFromTo(this, oldStart, oldEnd);
    oldSize = size(oldData);
    oldData = oldData(:, :);
    numColumns = size(oldData, 2);

    % Treat missing observations in input daily series
    for row = 1 : size(oldData, 1)
        inxNaN = isnan(oldData(row, :));
        if any(inxNaN)
            if any(strcmpi(opt.Missing, {'last', 'previous'}))
                if row>1
                    oldData(row, inxNaN) = oldData(row-1, inxNaN);
                else
                    oldData(row, inxNaN) = NaN;
                end
            else
                oldData(row, inxNaN) = opt.Missing;
            end
        end
    end

    newDatesSerial = dater.getSerial(newDates);
    newStartSerial = newDatesSerial(1);
    newEndSerial = newDatesSerial(end);
    numNewPeriods = newEndSerial - newStartSerial + 1;

    % Apply function period by period, column by column
    newData = nan(0, numColumns);
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

                if opt.RemoveNaN
                    inxToKeep = ~isnan(col__);
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
end%


function [newData, newStart] = locallyInterpolate(this, oldStart, oldEnd, oldFreq, newFreq, opt)
    %(
    if isequal(opt.Method, @default) || startsWith(opt.Method, "default", "ignoreCase", true)
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
        newStart = numeric.day2ww(oldStartDay);
        newEnd = numeric.day2ww(oldEndDay);
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
            newStart = numeric.dd(oldStartYear, startMonth, 1);
            newEnd = numeric.dd(oldEndYear, endMonth, eomday(oldEndYear, endMonth));
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
        newStart = numeric.datecode(newFreq, newStartYear, newStartPer);
        newEnd = numeric.datecode(newFreq, newEndYear, newEndPer);
    end

    oldData = getDataFromTo(this, oldStart, oldEnd);
    oldSize = size(oldData);
    if startsWith(opt.Method, ["flat", "first", "last"], "ignoreCase", true)
        newData = hereFlat( );
    else
        newData = hereInterpolate( );
    end

    return

        function newData = hereInterpolate( )
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


        function newData = hereFlat( )
            newRange = newStart : newEnd;
            oldRange = oldStart : oldEnd;
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


function [newData, newStart] = locallyInterpolateAndMatch(this, oldStart, oldEnd, oldFreq, newFreq, opt)
    n = newFreq/oldFreq;
    if n~=round(n)
        utils.error('tseries:convert', ...
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
    newStart = numeric.datecode(newFreq, newStartYear, newStartPer);

    [newData, flag] = interpolateAndMatchEval(oldData, n);
    if ~flag
        exception.warning([
            "Series:CannotInterpolateInsampleNaNs"
            "Cannot calculate the ""%s"" interpolation the time series "
            "with in-sample missing observations. "
        ], opt.Method);
    end
    if startsWith(opt.Method, ["quadAvg", "quadMean"], "ignoreCase", true)
        newData = newData*n;
    end
    newData = reshape(newData, [size(newData, 1), oldSize(2:end)]);
end% 




function [y2, flag] = interpolateAndMatchEval(y1, n)
    [nObs, ny] = size(y1);
    y2 = nan(nObs*n, ny);
    t1 = (1 : n)';
    t2 = (n+1 : 2*n)';
    t3 = (2*n+1 : 3*n)';
    M = [
        n, sum(t1), sum(t1.^2)
        n, sum(t2), sum(t2.^2)
        n, sum(t3), sum(t3.^2)
    ];
    flag = true;
    for i = 1 : ny
        iY1 = y1(:, i);
        [iSample, flagi] = getsample(iY1');
        flag = flag && flagi;
        if ~any(iSample)
            continue
        end
        iY1 = iY1(iSample);
        iNObs = numel(iY1);
        yy = [ iY1(1:end-2), iY1(2:end-1), iY1(3:end) ]';
        b = nan(3, iNObs);
        b(:, 2:end-1) = M \ yy;
        iY2 = nan(n, iNObs);
        for t = 2 : iNObs-1
            iY2(:, t) = b(1, t)*ones(n, 1) + b(2, t)*t2 + b(3, t)*t2.^2;
        end
        iY2(:, 1) = b(1, 2) + b(2, 2)*t1 + b(3, 2)*t1.^2;
        iY2(:, end) = b(1, end-1) + b(2, end-1)*t3 + b(3, end-1)*t3.^2;
        iSample = iSample(ones(1, n), :);
        iSample = iSample(:);
        y2(iSample, i) = iY2(:);
    end
end%




function data = first(data, varargin)
    data = data(1, :);
end%




function data = last(data, varargin)
    data = data(end, :);
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

