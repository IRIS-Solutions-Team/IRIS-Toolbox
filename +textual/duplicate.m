function outputList = duplicate(inputList)
% duplicate  Find duplicate entries in a list of names
%
% __Syntax__
%
%     DuplicateList = textual.duplicate(List)
%
%
% __Input Arguments__
%
% * `List` [ cellstr ] - Cell array of names.
%
%
% __Output Arguments__
%
% * `DuplicateList` [ cellstr ] - List of duplicate (nonunique) entries
% from the input list.
%
% 
% __Description__
%
% This function finds all entries that occur in the input list, `List`,
% more than once, and returns them with each such entry included only once
% in the output list, `DuplicateList`.
%
%
% __Example__
%
%
%     >> textual.duplicate({'a', 'b', 'c'})
%     ans =
%       1x0 empty cell array
%     >> textual.duplicate({'a', 'b', 'c', 'a', 'a', 'c'})
%     ans =
%       1x2 cell array
%         {'a'}    {'c'}
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

inputList = inputList(:)';
numInputList = numel(inputList);
[~, posUnique] = unique(inputList, 'last');
posDuplicate = 1:numInputList;
posDuplicate(posUnique) = [ ];
if isempty(posDuplicate)
    outputList = cell.empty(1, 0);
    return
end
outputList = inputList(posDuplicate);
outputList = unique(outputList, 'stable');

end
