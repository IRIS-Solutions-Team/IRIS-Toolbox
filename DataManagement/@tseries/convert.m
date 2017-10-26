function this = convert(this, newFreq, varargin)
% convert  Convert tseries object to a different frequency.
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Y = convert(X, NewFreq, ~Range, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input tseries object that will be converted to a new
% frequency, `freq`, aggregating or intrapolating the data.
%
% * `NewFreq` [ numeric | char ] - New frequency to which the input data
% will be converted: `1` or `'A'` for yearly, `2` or `'H'` for half-yearly, 
% `4` or `'Q'` for quarterly, `6` or `'B'` for bi-monthly, and `12` or
% `'M'` for monthly.
%
% * `Range` [ DateWrapper ] - Date range on which the input data will be
% converted; if omitted, the conversion will be done on the entire range.
%
%
% __Output Arguments__
%
% * `y` [ tseries ] - Output tseries created by converting `x` to the new
% frequency.
%
%
% __Options__
%
% * `'IgnoreNaN='` [ *`true`* | `false` ] - Exclude NaNs from agreggation.
%
% * `'Missing='` [ numeric | *`NaN`* | `'last'` ] - Replace missing
% observations with this value.
%
%
% __Options for High- to Low-Frequency Conversion (Aggregation)__
%
% * `'Method='` [ function_handle | `'first'` | `'last'` | *`@mean`* ] -
% Method that will be used to aggregate the high frequency data.
%
% * `'Select='` [ numeric | *`Inf`* ] - Select only these high-frequency
% observations within each low-frequency period; Inf means all observations
% will be used.
%
%
% __Options for Low- to High-Frequency Conversion (Interpolation)__
%
% * `'Method='` [ char | *`'cubic'`* | `'quadsum'` | `'quadavg'` ] -
% Interpolation method; any option available in the built-in `interp1`
% function can be used.
%
% * `'Position='` [ *`'centre'`* | `'start'` | `'end'` ] - Position of the
% low-frequency date grid.
%
%
% __Description__
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
% the data are processed en block columnwise. If this call fails, `convert`
% will attempt to call the function with just one input argument, the data, 
% but this is not a safe option under some circumstances since dimension
% mismatch may occur.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if isempty(this)
    utils.warning('tseries:convert', ...
        'Tseries object is empty, no conversion performed.');
    return
end

if ~isempty(varargin) && isnumeric(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
else
    range = Inf;
end

%--------------------------------------------------------------------------

if isnan(this.Start) && isempty(this.Data)
    return
end

if isempty(range)
    this = this.empty(this);
    return
end

% Resolve range, `range` is then a vector of dates with no `Inf`.
if ~all(isinf(range))
    this = resize(this, range);
end
range = specrange(this, range);

newFreq = recognizeFreq(newFreq);
if isempty(newFreq)
    utils.error('tseries:convert', ...
        'Cannot determine output frequency.');
end

fromFreq = DateWrapper.getFrequencyFromNumeric(this.Start);

if fromFreq==0 || newFreq==0
    utils.error('tseries:convert', ...
        'Cannot convert tseries from or to integer frequency.');
end

call = [ ];
if fromFreq==newFreq
    return
elseif fromFreq==365
    % Aggregation of daily series to lower frequencies.
    opt = passvalopt('tseries.convertaggregdaily', varargin{:});
    call = @aggregate;
elseif fromFreq==52
    if newFreq==365
        utils.error('tseries:convert', ...
            'Conversion from weekly to daily tseries not implemented yet.');
    else
        % Aggregation of weekly series to lower frequencies.
        opt = passvalopt('tseries.convertaggregdaily', varargin{:});
        call = @aggregate;
    end 
elseif newFreq~=365
    % Conversion of Y, Z, Q, B, or M series.
    if fromFreq>newFreq
        % Aggregate.
        opt = passvalopt('tseries.convertaggreg', varargin{:});
        if ~isempty(opt.function)
            opt.method = opt.function;
        end
        call = @aggregate;
    else
        % Interpolate.
        opt = passvalopt('tseries.convertinterp', varargin{:});
        if any(strcmpi(opt.method, {'quadsum', 'quadavg'}))
            if newFreq ~= 52
                % Quadratic interpolation matching sum or average.
                call = @interpolateAndMatch;
            end
        else
            % Built-in interp1.
            call = @interpolate;
        end
    end
end

if isa(call, 'function_handle')
    this = call(this, range, fromFreq, newFreq, opt);
else
    utils.error('tseries:conversion', ...
        'Cannot convert tseries from freq=%g to freq=%g.', ...
        fromFreq, newFreq);
end

end




function freq = recognizeFreq(freq)
    freqNum = [1, 2, 4, 6, 12, 52, 365];
    if ischar(freq)
        if ~isempty(freq)
            freqLetter = 'yhqbmwd';
            freq = lower(freq(1));
            freq = freqNum(freq==freqLetter);
        else
            freq = [ ];
        end
    elseif ~any(freq==freqNum)
        freq = [ ];
    end
end




function this = aggregate(this, range, fromFreq, toFreq, opt)
if ischar(opt.method)
	methodStr = lower(opt.method);
    if true % ##### MOSW
        opt.method = str2func(lower(opt.method));
    else
        Opt.method = mosw.str2func(lower(Opt.method)); %#ok<UNRCH>
    end
else
    methodStr = lower(func2str(opt.method));
end

% Stretch the original range from the beginning of first year until the end
% of last year.
if fromFreq==365
    [fromFirstYear, ~, ~] = datevec( double(range(1)) );
    [fromLastYear, ~, ~] = datevec( double(range(end)) );
    fromFirstDay = dd(fromFirstYear, 1, 1);
    fromLastDay = dd(fromLastYear, 12, 'end');
    range = fromFirstDay : fromLastDay;
    if toFreq==52
        toDates = day2ww(range);
    else
        [year, month] = datevec( double(range) );
        toDates = datcode(toFreq, year, ceil(toFreq*month/12));
    end
else
    fromFirstYear = dat2ypf(range(1));
    fromLastYear = dat2ypf(range(end));
    fromFirstDate = datcode(fromFreq, fromFirstYear, 1);
    fromLastDate = datcode(fromFreq, fromLastYear, 'end');
    range = fromFirstDate : fromLastDate;
    toDates = convert(range, toFreq, 'ConversionMonth=', opt.ConversionMonth);
end

fromData = rangedata(this, range);
fromSize = size(fromData);
fromData = fromData(:, :);
nCol = size(fromData, 2);

% Treat missing observations in input daily series.
for t = 1 : size(fromData, 1)
    ix = isnan(fromData(t, :));
    if any(ix)
        switch opt.missing
            case 'last'
                if t>1
                    fromData(t, ix) = fromData(t-1, ix);
                else
                    fromData(t, ix) = NaN;
                end
            otherwise
                fromData(t, ix) = opt.missing;
        end
    end
end

flToDates = floor(toDates);
nToPer = flToDates(end) - flToDates(1) + 1;

toStart = toDates(1);
toData = nan(0, nCol);
for t = flToDates(1) : flToDates(end)
    ix = t==flToDates;
    toX = nan(1, nCol);
    if any(ix)
        fromX = fromData(ix, :);
        for iCol = 1 : nCol
            iFromX = fromX(:, iCol);
            if opt.ignorenan
                iFromX = iFromX(~isnan(iFromX));
            end
            if ~isequal(opt.select, Inf)
                try
                    iFromX = iFromX(opt.select);
                catch
                    iFromX = [ ];
                end
            end
            if isempty(iFromX)
                toX(1, iCol) = NaN;
            else
                try
                    switch methodStr
                        case 'first'
                            toX(1, iCol) = iFromX(1, :);
                        case 'last'
                            toX(1, iCol) = iFromX(end, :);
                        otherwise
                            toX(1, iCol) = opt.method(iFromX, 1);
                    end
                catch %#ok<CTCH>
                    toX(1, iCol) = opt.method(iFromX);
                end
            end
        end
    end
    toData = [toData; toX]; %#ok<AGROW>
end

if length(fromSize)>2
    toSize = fromSize;
    toSize(1) = nToPer;
    toData = reshape(toData, toSize);
end

this = replace(this, toData, toStart);
end 




function this = interpolate(this, range1, fromFreq, toFreq, opt)
[xData, range1] = mygetdata(this, range1);
xSize = size(xData);
xData = xData(:, :);

[startYear1, startPer1] = dat2ypf(range1(1));
[endYear1, endPer1] = dat2ypf(range1(end));

if toFreq==52
    startMonth1 = per2month(startPer1, fromFreq, 'first');
    endMonth1 = per2month(endPer1, fromFreq, 'last');
    startDay1 = datenum(startYear1, startMonth1, 1);
    endDay1 = datenum(endYear1, endMonth1, eomday(endYear1, endMonth1));
    startDate2 = day2ww(startDay1);
    endDate2 = day2ww(endDay1);
    % Cut off the very first and very last week; it helps handle some weird
    % cases.
    startDate2 = startDate2 + 1;
    endDate2 = endDate2 - 1;
else
    startYear2 = startYear1;
    endYear2 = endYear1;
    % Find the earliest freq2 period contained (at least partially) in freq1
    % start period.
    startPer2 = 1 + floor((startPer1-1)*toFreq/fromFreq);
    % Find the latest freq2 period contained (at least partially) in freq1 end
    % period.
    endper2 = ceil((endPer1)*toFreq/fromFreq);
    startDate2 = datcode(toFreq, startYear2, startPer2);
    endDate2 = datcode(toFreq, endYear2, endper2);
end

range2 = startDate2 : endDate2;

grid1 = dat2dec(range1, opt.position);
grid2 = dat2dec(range2, opt.position);
xData2 = interp1(grid1, xData, grid2, opt.method, 'extrap');
if size(xData2, 1)==1 && size(xData2, 2)==length(range2)
    xData2 = xData2(:);
else
    xData2 = reshape(xData2, [size(xData2, 1), xSize(2:end)]);
end
this.Start = range2(1);
this.Data = xData2;
this = trim(this);
end 




function this = interpolateAndMatch(this, range1, fromFreq, toFreq, opt)
n = toFreq/fromFreq;
if n~=round(n)
    utils.error('tseries:convert', ...
        ['Source and target frequencies are incompatible ', ...
        'in ''%s'' interpolation.'], ...
        opt.method);
end

[xData, range1] = mygetdata(this, range1);
xSize = size(xData);
xData = xData(:, :);

[startYear1, startPer1] = dat2ypf(range1(1));
[endYear1, endPer1] = dat2ypf(range1(end));

startYear2 = startYear1;
endYear2 = endYear1;
% Find the earliest freq2 period contained (at least partially) in freq1
% start period.
startPer2 = 1 + floor((startPer1-1)*toFreq/fromFreq);
% Find the latest freq2 period contained (at least partially) in freq1 end
% period.
endPer2 = ceil((endPer1)*toFreq/fromFreq);
firstDate2 = datcode(toFreq, startYear2, startPer2);
lastDate2 = datcode(toFreq, endYear2, endPer2);
range2 = firstDate2 : lastDate2;

[xData2, flag] = interpolateAndMatchEval(xData, n);
if ~flag
    utils.warning('tseries:convert', ...
        ['Cannot compute ''%s'' interpolation for series ', ...
        'with in-sample NaNs.'], ...
        opt.method);
end
if strcmpi(opt.method, 'quadavg')
    xData2 = xData2*n;
end

xData2 = reshape(xData2, [size(xData2, 1), xSize(2:end)]);
this.Start = range2(1);
this.Data = xData2;
this = trim(this);
end 




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
end
