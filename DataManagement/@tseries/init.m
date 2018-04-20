function this = init(this, freq, serials, observations)
% init  Create start date and observations for new time series
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

serials = serials(:);
numOfDates = numel(serials);
sizeOfObservations = size(observations);
if sizeOfObservations(1)==0 && (all(isnan(serials)) || numOfDates==0)
    % No observations entered, return empty series
    this = createEmptySeries(this, sizeOfObservations);
    return
end

if sizeOfObservations(1)~=numOfDates
    throw( exception.Base('Series:DatesDataDimensionMismatch', 'error') );
end

ndimsOfData = ndims(observations);
observations = observations(:, :);

% Remove NaN serials
indexOfNaNSerials = isnan(serials);
if any(indexOfNaNSerials)
    observations(indexOfNaNSerials, :) = [ ];
    serials(indexOfNaNSerials) = [ ];
end

if isempty(serials)
    % No proper date entered, return empty series
    this = createEmptySeries(this, sizeOfObservations);
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
sizeOfObservations(1) = numOfDates;

this.Data = repmat(this.MissingValue, sizeOfObservations);
posOfObservations = round(serials - startSerial + 1);

% Assign user observations; higher dimensions will be preserved in
% this.Data
this.Data(posOfObservations, :) = observations;
this.Start = DateWrapper.fromSerial(freq, startSerial);

end%


function this = createEmptySeries(this, sizeOfObservations)
    sizeOfObservations(1) = 0;
    this.Start = DateWrapper(NaN);
    this.Data = repmat(this.MissingValue, sizeOfObservations);
end%

