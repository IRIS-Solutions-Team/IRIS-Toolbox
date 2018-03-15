function [x, range] = rangedata(this, range)
% rangedata  Retrieve Series data on continuous range
%
% __Syntax__
%
%     [Y, Range] = rangedata(X, Range)
%     [Y, Range] = rangedata(X, [StartDate, EndDate])
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Tseries object.
%
% * `Range` [ numeric ] - Continuous date range; data from Range(1) to
% Range(end) will be returned.
%
% * `StartDate` [ numeric ] - Start date of the range.
%
% * `EndDate` [ numeric ] - End date of the range.
%
%
% __Output Arguments__
%
% * `Y` [ numeric ] - Output data.
%
% * `Range` [ numeric ] - The actual entire date range from which the data
% come.
%
%
% __Description__
%
% The function is equivalent to calling
%
%     y = x(range(1):range(end));
%
% but it is more efficient for the special case of contiunous date ranges.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%-------------------------------------------------------------------------- 

%start = double(this.Start);
start = this.Start;

if nargin==1
    x = this.Data;
    range = [this.Start, this.Start+size(this.Data, 1)-1];
    return
elseif isequal(range, @all)
    range = Inf;
end

data = this.Data;
sizeData = size(data);
isEmptyRange =  isempty(range) || isequaln(range, NaN);
if isEmptyRange
    x = zeros([0, sizeData(2:end)]);
    return
end

if isnan(start) || isempty(data)
    x = nan([rnglen(range), sizeData(2:end)]);
    return
end

numColumns = prod(sizeData(2:end));

f1 = DateWrapper.getFrequencyFromNumeric(start);
f2 = DateWrapper.getFrequencyFromNumeric(range);
if ~isequal(range, Inf) && any(f2~=f1)
    f = unique([f1, f2], 'stable');
    lsFreq = DateWrapper.printFreqName(f);
    temp = sprintf('%s x ', lsFreq{:});
    temp(end-2:end) = '';
    throw( ...
        exception.Base('Series:FrequencyMismatch', 'error'), ...
        temp ...
        ); %#ok<GTARG>
end

%startRange = getFirst(range);
%endRange = getLast(range);
startRange = range(1);
endRange = range(end);

if isinf(startRange)
    % Range is Inf or [-Inf, ...].
    posStart = 1; 
else
    posStart = double(startRange) - double(start) + 1; 
    posStart = round(posStart);
end


if isinf(endRange)
    % Range is Inf or [..., Inf].
    posEnd = sizeData(1);
else
    posEnd = double(endRange) - double(start) + 1;
    posEnd = round(posEnd);
end

if posStart>posEnd
    x = nan(0, numColumns);
elseif posStart>=1 && posEnd<=sizeData(1)
    x = this.Data(posStart:posEnd, :);
elseif (posStart<1 && posEnd<1) || (posStart>sizeData(1) && posEnd>sizeData(1))
    x = nan(posEnd-posStart+1, numColumns);
elseif posStart>=1
    x = [ data(posStart:end, :); nan(posEnd-sizeData(1), numColumns) ];
elseif posEnd<=sizeData(1)
    x = [ nan(1-posStart, numColumns); data(1:posEnd, :) ];
else
    x = [ nan(1-posStart, numColumns); data(:, :); nan(posEnd-sizeData(1), numColumns) ];
end

if length(sizeData)>2
    x = reshape(x, [size(x, 1), sizeData(2:end)]);
end

% Return actual range if requested
if nargout>1
    range = start + (posStart : posEnd) - 1;
end

end
