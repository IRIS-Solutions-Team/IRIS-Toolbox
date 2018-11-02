function [data, dates] = getData(this, timeRef)
% getData  Get data for vector of dates from TimeSubscriptable object
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

%--------------------------------------------------------------------------

sizeData = size(this.Data);

if nargin<2 || isequal(timeRef, ':') || isequal(timeRef, Inf)
    data = this.Data;
    dates = this.Range;
    return
end

missingValue = this.MissingValue;

if isempty(timeRef)
    newSizeOfData = [0, sizeData(2:end)];
    data = repmat(missingValue, newSizeOfData);
    dates = startDateWhenEmpty(this);
    return
end

if isnumeric(timeRef) && ~isa(timeRef, 'DateWrapper') ...
    && all(round(timeRef)==timeRef)
    timeRef = DateWrapper(timeRef);
end

switch subsCase(this, timeRef)
    case {'NaD_[]', 'NaD_NaD', 'NaD_:'}
        data = repmat(missingValue, [0, sizeData(2:end)]);
        dates = Date.NaD;
        return
    case {'Date_[]', 'Date_NaD', 'Empty_[]', 'Empty_NaD'}
        data = repmat(missingValue, [0, sizeData(2:end)]);
        dates = startDateWhenEmpty(this);
        return
    case 'NaD_Date'
        numPeriods = numel(timeRef);
        data = repmat(missingValue, [numPeriods, sizeData(2:end)]);
        dates = timeRef;
        return
    case 'Empty_Date'
        assert( ...
            validateDate(this, timeRef), ...
            'TimeSubscriptable:subsref:IllegalSubscript', ...
            'Illegal date frequency in subscripted reference to %s object.', ... 
            class(this) ...
        );
        numPeriods = numel(timeRef);
        data = repmat(missingValue, [numPeriods, sizeData(2:end)]);
        dates = timeRef;
    case 'Date_Date'
        assert( ...
            validateDate(this, timeRef), ...
            'TimeSeries:subsref:IllegalSubscript', ...
            'Illegal date frequency in subscripted reference to %s object.', ... 
            class(this) ...
        );
        [data, ~, pos] = getDataNoFrills(this, timeRef, ':');
        if numel(sizeData)>2
            data = reshape(data, [size(data, 1), sizeData(2:end)]);
        end
        dates = addTo(this.Start, pos-1);
end

end
