function listDuplicate = getMultiple(list)
% getMultiple  Find entries with multiple occurrences in a list of names.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

t = tabulate(list);
count = [t{:, 2}];
listDuplicate = t(count>1, 1)';

%{
listDuplicate = cell(1, 0);

numNames = length(list); % Number of non-unique names.
[listUnique, posUnique, posDuplicate] = unique(list);
numUnique = length(posUnique); % Number of unique names.

if numUnique<numNames
    posDuplicate = repmat(posDuplicate, 1, numUnique);
    match = repmat(1:numUnique, numNames, 1);
    indexDuplicate = sum(posDuplicate==match, 1)>1;
    listDuplicate = listUnique(indexDuplicate);
    listDuplicate = fliplr(listDuplicate); % Matlab reports last occurrences in posDuplicate, flip to fix the order.
end
%}

end
