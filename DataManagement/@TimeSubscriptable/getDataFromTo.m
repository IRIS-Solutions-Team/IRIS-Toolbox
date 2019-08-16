function [x, actualFrom, actualTo] = getDataFromTo(this, from, to)
% getDataFromTo  Retrieve time series data from date to date
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

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

freqStart = DateWrapper.getFrequencyAsNumeric(this.Start);
serialOfStart = DateWrapper.getSerial(this.Start);
data = this.Data;
sizeData = size(data);
missingValue = this.MissingValue;

if ~isinf(serialFrom) && ~isinf(serialTo) && serialTo<serialFrom
    x = repmat(missingValue, [0, sizeData(2:end)]);
    actualStart = DateWrapper.empty(0, 0);
    actualEnd = DateWrapper.empty(0, 0);
    return
end

if isnan(serialOfStart) 
    if isinf(serialFrom) || isinf(serialTo)
        lenOfRange = 0;
    else
        lenOfRange = round(serialTo - serialFrom + 1);
    end
    x = repmat(missingValue, [lenOfRange, sizeData(2:end)]);
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
    posTo = sizeData(1);
else
    posTo = round(serialTo - serialOfStart + 1);
end

numOfColumns = prod(sizeData(2:end));
if posFrom>posTo
    x = repmat(missingValue, 0, numOfColumns);
elseif posFrom>=1 && posTo<=sizeData(1)
    x = this.Data(posFrom:posTo, :);
elseif (posFrom<1 && posTo<1) || (posFrom>sizeData(1) && posTo>sizeData(1))
    x = repmat(missingValue, posTo-posFrom+1, numOfColumns);
elseif posFrom>=1
    addMissingAfter = repmat(missingValue, posTo-sizeData(1), numOfColumns);
    x = [ data(posFrom:end, :); addMissingAfter ];
elseif posTo<=sizeData(1)
    addMissingBefore = repmat(missingValue, 1-posFrom, numOfColumns);
    x = [ addMissingBefore; data(1:posTo, :) ];
else
    addMissingBefore = repmat(missingValue, 1-posFrom, numOfColumns);
    addMissingAfter = repmat(missingValue, posTo-sizeData(1), numOfColumns);
    x = [ addMissingBefore; data(:, :); addMissingAfter ];
end

if numel(sizeData)>2
    x = reshape(x, [size(x, 1), sizeData(2:end)]);
end

if nargout>1
    actualFrom = DateWrapper.getDateCodeFromSerial(freqStart, serialOfStart + posFrom - 1);
    actualTo = DateWrapper.getDateCodeFromSerial(freqStart, serialOfStart + posTo - 1);
end

end%

