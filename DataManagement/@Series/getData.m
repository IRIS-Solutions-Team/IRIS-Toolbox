% getData  Get data on specified range from time series
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [data, dates, this] = getData(this, timeRef, varargin)

testColon = @(x) (ischar(x) || isstring(x)) && all(strcmpi(x, ':'));

% References to 2nd and higher dimensions
if ~isempty(varargin)
    this.Data = this.Data(:, varargin{:});
    if nargout>=3
        this.Comment = this.Comment(:, varargin{:});
        this = trim(this);
    end 
end

sizeData = size(this.Data);
thisStart = double(this.Start);
serialStart = dater.getSerial(thisStart);
freqStart = dater.getFrequency(thisStart);

if nargin<2 || testColon(timeRef) || isequal(timeRef, Inf)
    data = this.Data;
    dates = this.RangeAsNumeric;
    return
end

timeRef = double(timeRef);

if numel(timeRef)==2 && any(isinf(timeRef))
    [from, to] = resolveRange(this, timeRef);
    timeRef = dater.colon(from, to);
end

missingValue = this.MissingValue;

if isempty(timeRef)
    data = repmat(missingValue, [0, sizeData(2:end)]);
    dates = double.empty(0, 1);
    if nargout>2
        this = emptyData(this);
    end
    return
end

switch locallyDetermineCase(thisStart, timeRef)
    % case {'NaN_[]', 'NaN_NaN', 'NaN_:'}
    case {'NaN_[]', 'NaN_NaN'}
        data = repmat(missingValue, [0, sizeData(2:end)]);
        if nargout>1
            dates = Series.StartDateWhenEmpty;
            if nargout>2
                this = emptyData(this);
            end
        end
        return

    case {'Date_NaN', 'Empty_NaN'}
        data = repmat(missingValue, [0, sizeData(2:end)]);
        if nargout>1
            dates = Series.StartDateWhenEmpty;
            if nargout>2
                this = emptyData(this);
            end
        end
        return

    case 'NaN_Date'
        numPeriods = numel(timeRef);
        data = repmat(missingValue, [numPeriods, sizeData(2:end)]);
        if nargout>1
            dates = timeRef;
            if nargout>2
                this = emptyData(this);
            end
        end
        return

    case 'Date_Date'
        freqTimeRef = dater.getFrequency(timeRef);
        freqSeries = getFrequencyAsNumeric(this);
        if ~isnan(freqSeries) && ~all(freqTimeRef==freqSeries)
            exception.warning([
                "Series:FrequencyMismatch"
                "Date frequency mismatch between the time series and the requested dates."
            ]);
        end
        if nargout>=3
            [data, ~, pos, this] = getDataNoFrills(this, timeRef);
        else
            [data, ~, pos] = getDataNoFrills(this, timeRef);
        end
        if numel(sizeData)>2
            data = reshape(data, [size(data, 1), sizeData(2:end)]);
        end
        if nargout>1
            serialDates = serialStart + pos - 1;
            dates = dater.fromSerial(freqStart, serialDates); 
            dates = reshape(dates, 1, []);
        end
        return
end

end%

%
% Local Functions
%

function output = locallyDetermineCase(start, timeRef)
    %(
    if isequaln(timeRef, NaN)
        ref = 'NaN';
    elseif isempty(timeRef)
        ref = '[]';
    elseif isnumeric(timeRef)
        ref = 'Date';
    else
        exception.error([
            "Series:InvalidSubscript"
            "Invalid subscripted reference or assignment to Series object."
        ]);
    end

    freq = dater.getFrequency(start);
    if isnan(freq)
        start = 'NaN';
    else
        start = 'Date';
    end

    output = [start, '_', ref];
    %)
end%

