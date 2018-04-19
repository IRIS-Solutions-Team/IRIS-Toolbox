function [x, range] = getDataFromTo(this, serialFrom, serialTo)
% getDataFromTo  Retrieve time series data from serial to serial
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%-------------------------------------------------------------------------- 

if nargin==1
    x = this.Data;
    range = this.Range;
    return
end

frequency = getFrequency(this.Start);
serialStart = round(this.Start);
data = this.Data;
sizeOfData = size(data);
missingValue = this.MissingValue;

if ~isinf(serialFrom) && ~isinf(serialTo) && serialTo<serialFrom
    x = repmat(missingValue, [0, sizeOfData(2:end)]);
    return
end

if isinf(serialFrom)
    posFrom = 1; 
else
    posFrom = round(serialFrom - serialStart + 1);
end

if isinf(serialTo)
    posTo = sizeOfData(1);
else
    posTo = round(serialTo - serialStart + 1);
end

if isnan(serialStart) || isempty(data)
    lenOfRange = round(posTo - posFrom + 1);
    x = repmat(this.MissingValue, [lenOfRange, sizeOfData(2:end)]);
    return
end

numberOfColumns = prod(sizeOfData(2:end));
if posFrom>posTo
    x = repmat(missingValue, 0, numberOfColumns);
elseif posFrom>=1 && posTo<=sizeOfData(1)
    x = this.Data(posFrom:posTo, :);
elseif (posFrom<1 && posTo<1) || (posFrom>sizeOfData(1) && posTo>sizeOfData(1))
    x = repmat(missingValue, posTo-posFrom+1, numberOfColumns);
elseif posFrom>=1
    addMissingAfter = repmat(missingValue, posTo-sizeOfData(1), numberOfColumns);
    x = [ data(posFrom:end, :); addMissingAfter ];
elseif posTo<=sizeOfData(1)
    addMissingBefore = repmat(missingValue, 1-posFrom, numberOfColumns);
    x = [ addMissingBefore; data(1:posTo, :) ];
else
    addMissingBefore = repmat(missingValue, 1-posFrom, numberOfColumns);
    addMissingAfter = repmat(missingValue, posTo-sizeOfData(1), numberOfColumns);
    x = [ addMissingBefore; data(:, :); addMissingAfter ];
end

if length(sizeOfData)>2
    x = reshape(x, [size(x, 1), sizeOfData(2:end)]);
end

if nargout>1
    range = round(serialStart + (posFrom : posTo) - 1);
    range = DateWrapper.fromSerial(frequency, range);
end

end
