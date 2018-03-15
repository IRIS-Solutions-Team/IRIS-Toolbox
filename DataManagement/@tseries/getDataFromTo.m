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

freq = getFrequency(this.Start);
serialStart = round(this.Start);
data = this.Data;
sizeData = size(data);

if ~isinf(serialFrom) && ~isinf(serialTo) && serialTo<serialFrom
    x = zeros([0, sizeData(2:end)]);
    return
end

if isinf(serialFrom)
    posFrom = 1; 
else
    posFrom = round(serialFrom - serialStart + 1);
end

if isinf(serialTo)
    posTo = sizeData(1);
else
    posTo = round(serialTo - serialStart + 1);
end

if isnan(serialStart) || isempty(data)
    lenRange = round(posTo - posFrom + 1);
    x = nan([lenRange, sizeData(2:end)]);
    return
end

numColumns = prod(sizeData(2:end));
if posFrom>posTo
    x = nan(0, numColumns);
elseif posFrom>=1 && posTo<=sizeData(1)
    x = this.Data(posFrom:posTo, :);
elseif (posFrom<1 && posTo<1) || (posFrom>sizeData(1) && posTo>sizeData(1))
    x = nan(posTo-posFrom+1, numColumns);
elseif posFrom>=1
    x = [ data(posFrom:end, :); nan(posTo-sizeData(1), numColumns) ];
elseif posTo<=sizeData(1)
    x = [ nan(1-posFrom, numColumns); data(1:posTo, :) ];
else
    x = [ nan(1-posFrom, numColumns); data(:, :); nan(posTo-sizeData(1), numColumns) ];
end

if length(sizeData)>2
    x = reshape(x, [size(x, 1), sizeData(2:end)]);
end

if nargout>1
    range = round(serialStart + (posFrom : posTo) - 1);
    range = DateWrapper.fromSerial(frequency, range);
end

end
