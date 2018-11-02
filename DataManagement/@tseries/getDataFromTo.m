function [x, actualFrom, actualTo] = getDataFromTo(this, from, to)
% getDataFromTo  Retrieve time series data from date to date
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%-------------------------------------------------------------------------- 

% No frequency check can be performed here; this is a responsibility of the
% caller

if nargin==1
    x = this.Data;
    actualFrom = this.Start;
    actualTo = this.End;
    return
end

if nargin==2
    to = from;
end

% Input dates from and to may be either date codes or serials; convert to
% serials anyway
serialFrom = DateWrapper.getSerial(from);
serialTo = DateWrapper.getSerial(to);

freqOfStart = DateWrapper.getFrequencyAsNumeric(this.Start);
serialOfStart = DateWrapper.getSerial(this.Start);
data = this.Data;
sizeOfData = size(data);
missingValue = this.MissingValue;

if ~isinf(serialFrom) && ~isinf(serialTo) && serialTo<serialFrom
    x = repmat(missingValue, [0, sizeOfData(2:end)]);
    actualStart = DateWrapper.empty(0, 0);
    actualEnd = DateWrapper.empty(0, 0);
    return
end

if isinf(serialFrom)
    posFrom = 1; 
else
    posFrom = round(serialFrom - serialOfStart + 1);
end

if isinf(serialTo)
    posTo = sizeOfData(1);
else
    posTo = round(serialTo - serialOfStart + 1);
end

if isnan(serialOfStart) || isempty(data)
    lenOfRange = round(posTo - posFrom + 1);
    x = repmat(this.MissingValue, [lenOfRange, sizeOfData(2:end)]);
    actualStart = DateWrapper.empty(0, 0);
    actualEnd = DateWrapper.empty(0, 0);
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
    actualFrom = DateWrapper.getDateCodeFromSerial(freqOfStart, serialOfStart + posFrom - 1);
    actualTo = DateWrapper.getDateCodeFromSerial(freqOfStart, serialOfStart + posTo - 1);
end

end%

