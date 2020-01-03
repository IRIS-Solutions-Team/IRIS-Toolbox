function [c, s] = reportConsecutive(d, fromToSign)
% reportConsecutive  Group dates into continuous ranges
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if isempty(d)
    c = cell.empty(1, 0);
    s = cell.empty(1, 0);
    return
end

if nargin<2
    fromToSign = ':';
end

%--------------------------------------------------------------------------

c = { d(1) };
for i = 2 : numel(d)
    ithDate = d(i);
    if isempty(c{end}) || datdiff(ithDate, c{end}(end))==1
        c{end}(end+1) = ithDate;
    else
        c{end+1} = ithDate; %#ok<AGROW>
    end
end

if nargout==1
    return
end

s = cell(size(c));
for i = 1 : length(c)
    if length(c{i})==1
        s{i} = dat2char(c{i});
    else
        s{i} = [dat2char(c{i}(1)), fromToSign, dat2char(c{i}(end))];
    end
end

end%

