function [flag, outputList] = nonunique(inputList)
% nonunique  Find nonunique entries in a cellstr
%
% __Syntax__
%
%     [flag, duplicate] = textual.nonunique(List)
%
%
% __Input Arguments__
%
% * `list` [ cellstr ] - Cell array of names.
%
%
% __Output Arguments__
%
% * `flag` [ true | false ] - True if there are duplicate (nonunique)
% entries in the `list`.
%
% * `duplicate` [ cellstr ] - List of duplicate (nonunique) entries
% from the input list.
%
% 
% __Description__
%
% This function finds all entries that occur in the input list, `list`,
% more than once, and returns them with each such entry included only once
% in the output list, `duplicate`.
%
%
% __Example__
%
%
%     >> [flag, duplicate] = textual.nonunique({'a', 'b', 'c'})
%     flag = 
%       logical
%        0
%     duplicate =
%       1x0 empty cell array
%     >> [flag, duplicate] = textual.nonunique({'a', 'b', 'c', 'a', 'a', 'c'})
%     flag = 
%       logical
%        1
%     duplicate =
%       1x2 cell array
%         {'a'}    {'c'}
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

inputList = inputList(:)';
numInputList = numel(inputList);
[~, posUnique] = unique(inputList, 'last');
posDuplicate = 1:numInputList;
posDuplicate(posUnique) = [ ];
flag = ~isempty(posDuplicate);
if nargout==1
    return
end
if isempty(posDuplicate)
    outputList = cell.empty(1, 0);
    return
end
outputList = inputList(posDuplicate);
outputList = unique(outputList, 'stable');

end%

