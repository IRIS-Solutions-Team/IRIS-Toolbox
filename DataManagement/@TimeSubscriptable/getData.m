function [data, dates, this] = getData(this, timeRef, varargin)
% getData  Get data on specified range from TimeSubscriptable object
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

% timeRef can be one of the following
%
% * ':', Inf - data for the entire range available are returned
% * empty - empty data are returned
% * DateWrapper or integer - data for the specified date vector are returned

ERROR_INVALID_FREQUENCY = { 'TimeSeries:subsref:InvalidFrequency'
                            'Illegal date frequency in subscripted reference to %s object' };

%--------------------------------------------------------------------------

% References to 2nd and higher dimensions
if ~isempty(varargin)
    this.Data = this.Data(:, varargin{:});
    this.Comment = this.Comment(:, varargin{:});
end

sizeOfData = size(this.Data);
serialOfStart = DateWrapper.getSerial(this.Start);
freqOfStart = DateWrapper.getFrequencyAsNumeric(this.Start);

if nargin<2 || isequal(timeRef, ':') || isequal(timeRef, Inf)
    data = this.Data;
    dates = this.Range;
    return
end

missingValue = this.MissingValue;

if isempty(timeRef)
    data = repmat(missingValue, [0, sizeOfData(2:end)]);
    dates = DateWrapper.empty(0, 1);
    if nargout>2
        this = emptyData(this);
    end
    return
end

if isnumeric(timeRef) && ~isa(timeRef, 'DateWrapper') ...
   && all(round(timeRef)==timeRef)
    timeRef = DateWrapper(timeRef);
end

switch subsCase(this, timeRef)
    case {'NaD_[]', 'NaD_NaD', 'NaD_:'}
        data = repmat(missingValue, [0, sizeOfData(2:end)]);
        dates = startDateWhenEmpty(this);
        if nargout>2
            this = emptyData(this);
        end
        return
    case {'Date_NaD', 'Empty_NaD'}
        data = repmat(missingValue, [0, sizeOfData(2:end)]);
        dates = startDateWhenEmpty(this);
        if nargout>2
            this = emptyData(this);
        end
        return
    case 'NaD_Date'
        numOfPeriods = numel(timeRef);
        data = repmat(missingValue, [numOfPeriods, sizeOfData(2:end)]);
        dates = timeRef;
        if nargout>2
            this = emptyData(this);
        end
        return
    case 'Date_Date'
        if nargout>2
            [data, ~, pos, this] = getDataNoFrills(this, timeRef);
        else
            [data, ~, pos] = getDataNoFrills(this, timeRef);
        end
        if numel(sizeOfData)>2
            data = reshape(data, [size(data, 1), sizeOfData(2:end)]);
        end
        serialOfDates = serialOfStart + pos - 1;
        dates = DateWrapper.getDateCodeFromSerial(freqOfStart, serialOfDates); 
        dates = dates(:);
        if isa(this.Start, 'DateWrapper')
            dates = DateWrapper.fromDateCode(dates);
        end
end

end%

