function [data, indexLhx, posRhs] = getDataNoFrills(this, timeRef, varargin)

sizeData = size(this.Data);
ndimsData = numel(sizeData);

firstDate = getFirst(timeRef);
lastDate = getLast(timeRef);
switch sprintf('%g_%g', isinf(firstDate), isinf(lastDate))
    case '1_1'
        % x(-Inf:Inf)
        posRhs = 1 : sizeData(1);
    case '1_0'
        % x(-Inf:Date)
        posLast = rnglen(this.Start, lastDate);
        posRhs = 1 : posLast;
    case '0_1'
        % x(Date:Inf)
        posFirst = rnglen(this.Start, firstDate);
        posRhs = posFirst : sizeData(1);
    otherwise
        posRhs = rnglen(this.Start, timeRef);
end
posRhs = posRhs(:);

size1 = numel(posRhs);
indexLhx = posRhs>=1 & posRhs<=sizeData(1);

if ~isempty(varargin)
    refHigher = varargin;
else
    refHigher = cell(1, ndimsData-1);
    refHigher(:) = {':'};
end

if all(indexLhx)
    data = this.Data(posRhs, refHigher{:});
elseif ~any(indexLhx)
    data = repmat(this.MissingValue, [size1, sizeData(2:end)]);
    data = data(:, refHigher{:});
else
    tempData = this.Data(:, refHigher{:});
    sizeTempData = size(tempData);
    data = repmat(this.MissingValue, [size1, sizeTempData(2:end)]);
    data(indexLhx, :) = tempData(posRhs(indexLhx), :);
end

end
