function [data, start, first, last] = trimRows(data, start, missingValue, missingTest)
% trimRows  Trim leading and trailing rows with only NaNs in them
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

first = [ ];
last = [ ];

if isempty(data)
    return
end

dataFirst = data(1, :);
dataLast = data(end, :);
if ~all(missingTest(dataFirst)) && ~all(missingTest(dataLast))
    return
end

sizeData = size(data);
inxMissing = all(missingTest(data(:, :)), 2);
if all(inxMissing)
    first = 1;
    last = 0;
    data = repmat(missingValue, [0, sizeData(2:end)]);
    start = NaN;
    return
end

first = find(~inxMissing, 1);
last = find(~inxMissing, 1, 'last');
n = last - first + 1;
data = reshape(data(first:last, :), [n, sizeData(2:end)]);
start = double(start);
start = start + first - 1; 

end%

