function [data, dates] = getData(this, timeRef)

sizeOfData = size(this.Data);

if nargin<2 || isequal(timeRef, ':') || isequal(timeRef, Inf)
    data = this.Data;
    dates = addTo(this.Start, 0:sizeOfData(1)-1);
    return
end

missingValue = this.MissingValue;

if isempty(timeRef)
    newSizeOfData = [0, sizeOfData(2:end)];
    data = repmat(missingValue, newSizeOfData);
    dates = Date.empty(this.Start);
    return
end

switch this.subsCase(this.Start, timeRef)
    case {'NaD_[]', 'NaD_NaD', 'NaD_:'}
        data = repmat(missingValue, [0, sizeOfData(2:end)]);
        dates = Date.NaD;
        return
    case {'Date_[]', 'Date_NaD', 'Empty_[]', 'Empty_NaD'}
        data = repmat(missingValue, [0, sizeOfData(2:end)]);
        dates = empty(this.Start);
        return
    case 'NaD_Date'
        size1 = numel(timeRef);
        data = repmat(missingValue, [size1, sizeOfData(2:end)]);
        dates = timeRef;
        return
    case 'Empty_Date'
        assert( ...
            validate(this.Start, timeRef), ...
            'TimeSeries:subsref', ...
            'Invalid date frequency in subscripted reference to TimeSeries.' ... 
        );
        nTime = numel(timeRef);
        data = repmat(missingValue, [nTime, sizeOfData(2:end)]);
        dates = timeRef;
    case 'Date_Date'
        assert( ...
            validate(this.Start, timeRef), ...
            'TimeSeries:subsref', ...
            'Invalid date frequency in subscripted reference to TimeSeries.' ... 
        );
        [data, ~, pos] = getDataNoFrills(this, timeRef, ':');
        if numel(sizeOfData)>2
            data = reshape(data, [size(data, 1), sizeOfData(2:end)]);
        end
        dates = addTo(this.Start, pos-1);
end

end
