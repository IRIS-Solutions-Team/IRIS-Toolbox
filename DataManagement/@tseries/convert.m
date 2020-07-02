function this = convert(this, newFreq, varargin)
% convert  Convert timer series to different frequency
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     Y = convert(X, NewFreq, ~Range, ...)
%
%
% ## Input Arguments ##
%
% __`X`__ [ Series ] -
% Input tseries object that will be converted to a new
% frequency, `freq`, aggregating or intrapolating the data.
%
% __`NewFreq`__ [ Frequency | numeric | char ] -
% New frequency to which the
% input data will be converted; see Description for frequency formats
% allowed.
%
% __`~Range`__ [ DateWrapper ] -
% Date range on which the input data will be
% converted; if omitted, the conversion will be done on the entire range.
%
%
% ## Output Arguments ##
%
% __`y`__ [ tseries ] -
% Output tseries created by converting `x` to the new
% frequency.
%
%
% ## Options ##
%
% __`RemoveNaN=false`__ [ `true` | `false` ] -
% Exclude NaNs from agreggation.
%
% __`Missing=NaN`__ [ numeric | `'previous'` ] -
% Replace missing observations with this value.
%
%
% ## Options for High- to Low-Frequency Aggregation ##
%
%
% __`Method=@mean`__ [ function_handle | `@first` | `@last` | `@random` ] -
% Aggregation method; `'first'`, `'last'` and `'random'` select the
% first, last or a random observation from the high-frequency periods
% contained in the correspoding low-frequency period.
%
%
% __`Select=Inf`__ [ numeric ] -
% Select only these high-frequency observations within each low-frequency
% period; `Inf` means all observations will be used.
%
%
% ## Options for Low- to High-Frequency Interpolation ##
%
% __`Method='pchip'`__ [ char | `'QuadSum'` | `'QuadAvg'` | `'Flat'` | `'WriteToEnd'` ] -
% Interpolation method; any option valid for the built-in function
% `interp1` can be used, or `'quadsum'` or `'quadavg'`; these two options
% use quadratic interpolation preserving the sum or the average of
% observations within each period.
%
% __`Position='center'`__ [ `'center'` | `'start'` | `'end'` ] -
% Position of dates within each period in the low-frequency date grid.
%
%
% ## Description ##
%
% The function handle that you pass in through the 'method' option when you
% aggregate the data (convert higher frequency to lower frequency) should
% behave like the built-in functions `mean`, `sum` etc. In other words, it
% is expected to accept two input arguments:
%
% * the data to be aggregated, 
% * the dimension along which the aggregation is calculated.
%
% The function will be called with the second input argument set to 1, as
% the data are processed en block columnwise. If this call fails,
% `convert(~)` will attempt to call the function with just one input
% argument, the data, but this is not a safe option under some
% circumstances since dimension mismatch may occur.
%
%
% ### Frequency Format ###
%
% The new frequency, `NewFreq`, needs to be a proper frequency (yearly,
% half-yearly, quarterly, monthly, weekly, daily, but not integer or `NaF`)
% and can be specified in one of the following three formats; for each
% format:
%
% * as a Frequency enumeration: `Frequency.YEARLY`, `Frequency.HALFYEARLY`,
% `Frequency.QUARTERLY`, `Frequency.MONTHLY`, `Frequency.WEEKLY`,
% `Frequency.DAILY`;
%
% * as a numeric value (indicating the number of periods within a calendar
% year): `1`, `2`, `4`, `12`, `52`, `365`;
%
% * as a letter (the first letter of the respective frequency name): `y`,
% `h`, `q`, `m`, `w`, `d`.
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

if isempty(this)
    return
end

if ~isempty(varargin) && isnumeric(varargin{1})
    range = double(varargin{1});
    varargin(1) = [ ];
else
    range = Inf;
end

persistent pp
if isempty(pp)
    pp = extend.InputParser('TimeSubscriptable.convert');
    addRequired(pp, 'InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    addRequired(pp, 'NewFreq', @Frequency.validateProperFrequency);
    addParameter(pp, {'ConversionMonth', 'StandinMonth'}, 1, @(x) (isnumeric(x) && isscalar(x) && x==round(x)) || strcmpi(x, 'First') || strcmpi(x, 'Last'));
    addParameter(pp, {'RemoveNaN', 'IgnoreNaN', 'OmitNaN'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Missing', NaN, @(x) (ischar(x) && any(strcmpi(x, {'Last', 'Previous'}))) || validate.numericScalar(x));
    addParameter(pp, {'Method', 'Function'}, @default, @(x) isequal(x, @default) || isa(x, 'function_handle') || validate.string(x) || (isnumeric(x) && ~isempty(x)));
    addParameter(pp, 'Position', 'center', @(x) ischar(x) && any(strncmpi(x, {'c', 's', 'e'}, 1)));
    addParameter(pp, 'Select', Inf, @(x) isnumeric(x));
end
parse(pp, this, newFreq, varargin{:});
opt = pp.Options;

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

oldFreq = DateWrapper.getFrequencyAsNumeric(this.Start);

if oldFreq==newFreq
    return
end

if oldFreq==0 || newFreq==0
    throw( exception.Base('Series:CannotConvertIntegerFreq', 'error') )
end

if oldFreq>newFreq
    % Aggregate
    conversionFunc = @localAggregate;
else
    % Weekly to daily intepolation not implemented
    if oldFreq==52 && newFreq==365
        throw( exception.Base('Series:CannotConvertWeeklyToDaily', 'error') )
    end
    % Interpolate matching sum or average
    if any(strcmpi(opt.Method, {'quadsum', 'quadavg'}))
        conversionFunc = @localInterpolateAndMatch;
    else
        % Built-in interp1
        conversionFunc = @localInterpolate;
    end
end

[oldStart, oldEnd] = resolveRange(this, range(1), range(end));
[newData, newStart] = conversionFunc(this, oldStart, oldEnd, oldFreq, newFreq, opt);
this = fill(this, newData, newStart, this.Comment, this.UserData);

end%


%
% Local functions
%


function [newData, newStart] = localAggregate(this, oldStart, oldEnd, oldFreq, newFreq, opt)
    charMethod = char(opt.Method);
    if strcmpi(charMethod, 'Default')
        opt.Method = @mean;
    elseif strcmpi(charMethod, 'Last')
        opt.Method = 'last';
    elseif strcmpi(charMethod, 'First')
        opt.Method = 'first';
    elseif strcmpi(charMethod, 'Random')
        opt.Method = 'random';
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
        newDates = numeric.convert( oldStart:oldEnd, newFreq, ...
                                    'ConversionMonth=', opt.ConversionMonth );
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

    newDatesSerial = DateWrapper.getSerial(newDates);
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
                    if isnumeric(method__)
                        method__ = method__(inxToKeep);
                    end
                end

                if ~isequal(opt.Select, Inf)
                    try
                        col__ = col__(opt.Select);
                        if isnumeric(method__)
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

                if isnumeric(method__)
                    try %#ok<TRYNC>
                        newAdd(1, col) = method__*col__;
                    end
                elseif isa(method__, 'function_handle') || ischar(method__) || isa(method__, 'string')
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
    newStart = DateWrapper.getDateCodeFromSerial(newFreq, newStartSerial);
end%




function [newData, newStart] = localInterpolate(this, oldStart, oldEnd, oldFreq, newFreq, opt)
    if isequal(opt.Method, @default) || strcmpi(opt.Method, 'Default')
        opt.Method = 'pchip';
    elseif strcmpi(opt.Method, 'WriteToBeginning')
        opt.Method = 'First';
    elseif strcmpi(opt.Method, 'WriteToEnd')
        opt.Method = 'Last';
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
        newStart = newStart + 1;
        newEnd = newEnd - 1;
    elseif newFreq==Frequency.DAILY
        startMonth = per2month(oldStartPer, oldFreq, 'first');
        endMonth = per2month(oldEndPer, oldFreq, 'last');
        newStart = numeric.dd(oldStartYear, startMonth, 1);
        newEnd = numeric.dd(oldEndYear, endMonth, eomday(oldEndYear, endMonth));
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
    if any(strcmpi(opt.Method, {'Flat', 'First', 'Last'})) 
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
            newData = interp1(oldGrid, oldData, newGrid, opt.Method, 'extrap');
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
            if strcmpi(opt.Method, 'Flat')
                testPeriods = true(size(newConverted));
            else
                [~, newPeriods] = dat2ypf(newRange);
                if strcmpi(opt.Method, 'Last')
                    testPeriods = newPeriods==newFreq;
                elseif strcmpi(opt.Method, 'First')
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
end%




function [newData, newStart] = localInterpolateAndMatch(this, oldStart, oldEnd, oldFreq, newFreq, opt)
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
        utils.warning('tseries:convert', ...
            ['Cannot compute ''%s'' interpolation for series ', ...
            'with in-sample NaNs.'], ...
            opt.Method);
    end
    if strcmpi(opt.Method, 'quadavg')
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

