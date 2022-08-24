% replaceNames  Replace selected model names with new ones
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = replaceNames(this, oldNames, newNames)

% >=R2019b
%{
arguments
    this model.Quantity
    oldNames (1, :) string {locallyValidateOldNames(this, oldNames)}
    newNames (1, :) string {locallyValidateNames(oldNames, newNames)}
end
%}
% >=R2019b


    allOldNames = access(this, "names");
    allNewNames = allOldNames;
    for pair = [oldNames; newNames]
        inx = allOldNames==pair(1);
        allNewNames(inx) = pair(2);
    end

    [flag, list] = textual.nonunique(allNewNames);
    if flag
        exception.error([
            "Model:NonuniqueNames"
            "This new name now exists multiple times in the Model object: %s"
        ], list);
    end

    this.Name = allNewNames;

end%

%
% Local validators
%

function locallyValidateOldNames(this, oldNames)
    modelNames = access(this, "names");
    inxFound = ismember(oldNames, modelNames);
    if any(~inxFound)
        error("These names do not exist in the model object: %s", join(oldNames(~inxFound), ", "));
    end
end%


function locallyValidateNames(oldNames, newNames)
    if numel(unique(newNames))~=numel(newNames)
        error("New names must be all unique.");
    end
    if numel(oldNames)==numel(newNames)
        return
    end
    error("The list of new names must have the same number of elements as the list of existing names.");
end%

