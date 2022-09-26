%{
% 
% # `islog` ^^(Model)^^
% 
% {== True for empty model object==}
% 
% 
% ## Syntax 
% 
%     Flag = islog(M,Name)
% 
% 
% ## Input arguments 
% 
% `M` [ model ]
% > 
% > Model object.
% > 
% 
% `Name` [ char | cellstr ] 
% >
% > Name or names of model variable(s).
% >
% 
% ## Output arguments 
% 
% `Flag` [ `true` | `false` ]
% > 
% > True for log variables.
% > 
% 
% 
% ## Options 
% 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
%}
% --8<--


function flag = isLog(this, names)

    names = string(names);
    flag = false(size(names));
    modelNames = string(this.Quantity.Name);

    inxValid = ismember(names, modelNames);
    if any(~inxValid)
        exception.error([
            "Model"
            "This is not a valid name in the model object: %s"
        ], names(~inxValid));
    end

    for i = 1 : numel(names)
        flag(i) = this.Quantity.IxLog(modelNames==names(i));
    end

end%

