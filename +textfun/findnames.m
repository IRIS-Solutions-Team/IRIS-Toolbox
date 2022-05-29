function [pos, lsNotFound] = findnames(list, select, pattern)
% findnames  Find positions of strings in a list.
%
% Syntax
% =======
%
%     [Pos, NotFound] = textfun.findnames(List, Select)
%
% Input arguments
% ================
%
% * `List` [ cellstr ] - List of items that will be searched.
%
% * `Select` [ cellstr | char ] List of items that will be looked for.
%
% Output arguments
% =================
%
% * `Pos` [ numeric ] - Positions of `Select` items in `List`; if some
% `Select` items are not found, the position will be `NaN`.
%
% * `NotFound` [ cellstr ] - List of `Select` items not found in `List`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if nargin<3
   pattern = '\w+';
end

if ischar(list)
   list = regexp(list, pattern, 'match');
end
list = list(:).';

if ischar(select)
   select = regexp(select, pattern, 'match');
end
select = select(:).';

%--------------------------------------------------------------------------

pos = nan(size(select));
for i = 1 : length(select(:))
   tmp = strcmp(list, select{i});
   if any(tmp)
      pos(i) = find(tmp, 1);
   end
end

if nargout<2
    return
end

lsNotFound = select(isnan(pos));
lsNotFound = lsNotFound(:).';

end
