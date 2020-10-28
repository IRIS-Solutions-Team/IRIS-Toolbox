% reportConsecutive  Group dates into continuous ranges
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

function [c, s] = reportConsecutive(inputDates, fromToSign)

inputDates = double(inputDates);

if isempty(inputDates)
    c = cell.empty(1, 0);
    s = string.empty(1, 0);
    return
end

if nargin<2
    fromToSign = ":";
end

%--------------------------------------------------------------------------

c = {inputDates(1)};
for i = 2 : numel(inputDates)
    date__ = inputDates(i);
    if isempty(c{end}) || dater.minus(date__, c{end}(end))==1
        c{end}(end+1) = date__;
    else
        c{end+1} = date__; %#ok<AGROW>
    end
end

if nargout==1
    return
end

s = repmat("", size(c));
for i = 1 : numel(c)
    if numel(c{i})==1
        s(i) = dater.toDefaultString(c{i});
    else
        s(i) = dater.toDefaultString(c{i}(1)) + fromToSign + dater.toDefaultString(c{i}(end));
    end
end

end%

