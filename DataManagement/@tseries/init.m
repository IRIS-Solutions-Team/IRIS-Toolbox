function this = init(this, freq, serials, data)
% init  Create start date and data for new time series
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

serials = serials(:);
numOfDates = numel(serials);
sizeOfData = size(data);
if sizeOfData(1)==0 && (all(isnan(serials)) || numOfDates==0)
    % No data entered, return empty series
    this = createEmptySeries(this, sizeOfData);
    return
end

if sizeOfData(1)~=numOfDates
    throw( exception.Base('Series:DatesDataDimensionMismatch', 'error') );
end

ndimsOfData = ndims(data);
data = data(:, :);

% Remove NaN serials
inxOfNaNSerials = isnan(serials);
if any(inxOfNaNSerials)
    data(inxOfNaNSerials, :) = [ ];
    serials(inxOfNaNSerials) = [ ];
end

if isempty(serials)
    % No proper date entered, return empty series
    this = createEmptySeries(this, sizeOfData);
    return
end

% Start date is the minimum date found
startSerial = min(serials);
endSerial = max(serials);

% The actual stretch of the time series range
numOfDates = round(endSerial - startSerial + 1);
if isempty(numOfDates)
    numOfDates = 0;
end
sizeOfData(1) = numOfDates;

this.Data = repmat(this.MissingValue, sizeOfData);
posOfData = round(serials - startSerial + 1);

% Assign user data; higher dimensions will be preserved in
% this.Data
this.Data(posOfData, :) = data;
this.Start = DateWrapper.fromSerial(freq, startSerial);

end%

%
% Local functions
%

function this = createEmptySeries(this, sizeOfData)
    sizeOfData(1) = 0;
    this.Start = DateWrapper(NaN);
    this.Data = repmat(this.MissingValue, sizeOfData);
end%

