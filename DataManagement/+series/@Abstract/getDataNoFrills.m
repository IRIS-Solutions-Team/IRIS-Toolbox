function [data, indexOfLhs, posOfRhs] = getDataNoFrills(this, timeRef, varargin)

sizeData = size(this.Data);
ndimsData = numel(sizeData);

firstDate = getFirst(timeRef);
lastDate = getLast(timeRef);
switch sprintf('%g_%g', isinf(firstDate), isinf(lastDate))
    case '1_1'
        % x(-Inf:Inf)
        posOfRhs = 1 : sizeData(1);
    case '1_0'
        % x(-Inf:Date)
        posLast = rnglen(this.Start, lastDate);
        posOfRhs = 1 : posLast;
    case '0_1'
        % x(Date:Inf)
        posFirst = rnglen(this.Start, firstDate);
        posOfRhs = posFirst : sizeData(1);
    otherwise
        posOfRhs = rnglen(this.Start, timeRef);
end
posOfRhs = posOfRhs(:);

size1 = numel(posOfRhs);
indexOfLhs = posOfRhs>=1 & posOfRhs<=sizeData(1);

if ~isempty(varargin)
    refHigher = varargin;
else
    refHigher = cell(1, ndimsData-1);
    refHigher(:) = {':'};
end

if all(indexOfLhs)
    data = this.Data(posOfRhs, refHigher{:});
elseif ~any(indexOfLhs)
    data = repmat(this.MissingValue, [size1, sizeData(2:end)]);
    data = data(:, refHigher{:});
else
    tempData = this.Data(:, refHigher{:});
    sizeTempData = size(tempData);
    data = repmat(this.MissingValue, [size1, sizeTempData(2:end)]);
    data(indexOfLhs, :) = tempData(posOfRhs(indexOfLhs), :);
end

end
