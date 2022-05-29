% -Copyright (c) 2007-2022 IRIS Solutions Team
% -IRIS Macroeconomic Modeling Toolbox

function y = shift(x, shifts)

if nargin<2
   shifts = -1;
end

if isempty(shifts)
    y = numeric.empty(x, 2);
    return
end

sizeX = size(x);
ndimsX = ndims(x);
if ndimsX>2
    x = x(:, :);
end

[numPeriods, numColumns] = size(x);
y = [ ];
for k = 1 : numel(shifts)
    ithShift = shifts(k);
    if ithShift>0
        tmp = [x(1+ithShift:end, :); nan([min([numPeriods, ithShift]), numColumns])];
    elseif ithShift<0
        tmp = [nan([min([-ithShift, numPeriods]), numColumns]); x(1:end+ithShift, :)];
    else
        tmp = x;
    end
    if ndimsX>2
        tmp = reshape(tmp, sizeX);
    end
    y = [y, tmp];
end

end%

