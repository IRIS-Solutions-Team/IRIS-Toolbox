%{
% 
% # `islog` ^^(Model)^^
% 
% {== True for variables declared as log-variables ==}
% 
% 
% ## Syntax 
% 
%     flag = isLog(m, name)
% 
% 
% ## Input arguments 
% 
% __`m`__ [ model ]
% > 
% > Model object.
% > 
% 
% __`name`__ [ string ] 
% >
% > Name or names of model variable(s).
% > 
% 
% ## Output arguments 
% 
% `flag` [ `true` | `false` ]
% > 
% > The output flag is `true` for log variables, `false` otherwise.
% > 
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

