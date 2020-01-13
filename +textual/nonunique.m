function [flag, outputList] = nonunique(inputList)
% nonunique  Find nonunique entries in a list
%{
% ## Syntax ##
%
%     [flag, duplicate] = textual.nonunique(List)
%
%
% ## Input Arguments ##
%
%
% __`inputList`__ [ cellstr | string ]
% >
% List of strings; either a cell array of chars or an array of strings.
%
%
% ## Output Arguments ##
%
%
% __`flag`__ [ `true` | `false` ]
% >
% True if there are duplicate (nonunique) entries in the `inputList`.
%
%
% __`duplicate`__ [ cellstr | string ]
% >
% List of duplicate (nonunique) entries from the `inputList`; the
% `duplicate` list is the same type as the `inputList` (either a cell array
% of chars or a string array). 
%
% 
% ## Description ##
%
%
% This function finds all entries that occur in the `inputList`, more than
% once, and returns them with each such entry included only once in the
% output list, `duplicate`.
%
%
% ## Example ##
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
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

inputClass = class(inputList);

inputList = reshape(cellstr(inputList), 1, [ ]);
numInputList = numel(inputList);
[~, posUnique] = unique(inputList, 'last');
posDuplicate = 1:numInputList;
posDuplicate(posUnique) = [ ];
flag = ~isempty(posDuplicate);
if nargout==1
    return
end

outputList = cell.empty(1, 0);
if ~isempty(posDuplicate)
    outputList = inputList(posDuplicate);
    outputList = unique(outputList, 'stable');
end

if strcmp(inputClass, 'string')
    outputList = string(outputList);
end

end%

