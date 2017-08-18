function [data, ixLhs, posRhs] = getDataNoFrills(this, timeRef, varargin)

sizeData = size(this.Data);
ndimsData = numel(sizeData);

firstDate = getFirst(timeRef);
lastDate = getLast(timeRef);
switch string(isinf(firstDate)) + "_" + string(isinf(lastDate));
    case "true_true"
        % x(-Inf:Inf)
        posRhs = 1 : sizeData(1);
    case "true_false"
        % x(-Inf:Date)
        posLast = between(this.Start, lastDate);
        posRhs = 1 : posLast;
    case "false_true"
        % x(Date:Inf)
        posFirst = between(this.Start, firstDate);
        posRhs = posFirst : sizeData(1);
    otherwise
        posRhs = between(this.Start, timeRef);
end
posRhs = posRhs(:);

size1 = numel(posRhs);
ixLhs = posRhs>=1 & posRhs<=sizeData(1);

if ~isempty(varargin)
    refHigher = varargin;
else
    refHigher = cell(1, ndimsData-1);
    refHigher(:) = {':'};
end

if all(ixLhs)
    data = this.Data(posRhs, refHigher{:});
elseif ~any(ixLhs)
    data = repmat(this.MissingValue, [size1, sizeData(2:end)]);
    data = data(:, refHigher{:});
else
    tempData = this.Data(:, refHigher{:});
    sizeTempData = size(tempData);
    data = repmat(this.MissingValue, [size1, sizeTempData(2:end)]);
    data(ixLhs, :) = tempData(posRhs(ixLhs), :);
end

end
