% Type `web +textual/nonunique.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [flag, nonuniques, posUniques] = nonunique(inputList)

inputClass = class(inputList);

inputList = reshape(cellstr(inputList), 1, [ ]);
numInputList = numel(inputList);
[~, posUniques] = unique(inputList, "last");
posNonuniques = 1:numInputList;
posNonuniques(posUniques) = [ ];
flag = ~isempty(posNonuniques);

if nargout==1
    return
end

nonuniques = cell.empty(1, 0);
if ~isempty(posNonuniques)
    nonuniques = inputList(posNonuniques);
    nonuniques = unique(nonuniques, "stable");
end

if strcmp(inputClass, "string")
    nonuniques = string(nonuniques);
end

end%

