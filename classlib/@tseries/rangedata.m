function [x, range] = rangedata(this, range)
% rangedata  Retrieve Series data on continuous range.
%
% Syntax
% =======
%
%     [Y, Range] = rangedata(X, Range)
%     [Y, Range] = rangedata(X, [StartDate, EndDate])
%
%
% Input arguments
% ================
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
% Output arguments
% =================
%
% * `Y` [ numeric ] - Output data.
%
% * `Range` [ numeric ] - The actual entire date range from which the data
% come.
%
%
% Description
% ============
%
% The function is equivalent to calling
%
%     y = x(range(1):range(end));
%
% but it is more efficient for the special case of contiunous date ranges.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%-------------------------------------------------------------------------- 

start = double(this.Start);

if nargin==1
    x = this.Data;
    range = [this.Start, this.Start+size(this.Data, 1)-1];
    return
else
    range = double(range);
end

if isequal(range, @all)
    range = Inf;
end

data = this.Data;
size_ = size(data);
isEmptyRange =  isempty(range) || isequaln(range, NaN);
if isEmptyRange
    x = zeros([0, size_(2:end)]);
    return
end

if isnan(start) || isempty(data)
    x = nan([rnglen(range), size_(2:end)]);
    return
end

nCol = prod(size_(2:end));

f1 = datfreq(start);
f2 = datfreq(range);
if ~isequal(range, Inf) && any(f2~=f1)
    f = unique([f1, f2], 'stable');
    lsFreq = dates.Date.printFreqName(f);
    temp = sprintf('%s x ', lsFreq{:});
    temp(end-2:end) = '';
    throw( ...
        exception.Base('Series:FrequencyMismatch', 'error'), ...
        temp ...
        ); %#ok<GTARG>
end

if isinf(range(1))
    % Range is Inf or [-Inf, ...].
    posStart = 1; 
else
    posStart = round(range(1) - start + 1);
end

if isinf(range(end))
    % Range is Inf or [..., Inf].
    posEnd = size_(1);
else
    posEnd = round(range(end) - start + 1);
end

if posStart>posEnd
    x = nan(0, nCol);
elseif posStart>=1 && posEnd<=size_(1)
    x = this.Data(posStart:posEnd, :);
elseif (posStart<1 && posEnd<1) || (posStart>size_(1) && posEnd>size_(1))
    x = nan(posEnd-posStart+1, nCol);
elseif posStart>=1
    x = [ data(posStart:end, :); nan(posEnd-size_(1), nCol) ];
elseif posEnd<=size_(1)
    x = [ nan(1-posStart, nCol); data(1:posEnd, :) ];
else
    x = [ nan(1-posStart, nCol); data(:, :); nan(posEnd-size_(1), nCol) ];
end

if length(size_)>2
    x = reshape(x, [size(x, 1), size_(2:end)]);
end

% Return actual range if requested.
if nargout>1
    range = start + (posStart : posEnd) - 1;
end

end
