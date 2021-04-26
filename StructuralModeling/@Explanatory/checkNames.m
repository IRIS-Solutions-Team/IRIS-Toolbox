% checkNames  Check all names in Explanatory array for multiple occurrencies
%{
% Backend [IrisToolbox] method
% No help provided
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function checkNames(this)

for this__ = reshape(this, 1, [ ])
    checkList = [this__.VariableNames, this__.ControlNames];
    if isfinite(this__.PosLhsName)
        checkList = [checkList, this__.ResidualName, this__.FittedName];
    end

    %
    % Find multiple occurrences of the same name including ResidualName,
    % FittedName and ControlName
    %
    [flag, nameConflicts] = textual.nonunique(checkList);
    if flag
        exception.error([
            "Explanatory:MultipleNames"
            "This name is declared more than once in an Explanatory object "
            "(including ResidualName, FittedName and ControlNames): %s "
        ], string(nameConflicts));
    end

    %
    % Make sure all names are valid Matlab names
    %
    inxValid = arrayfun(@isvarname, checkList);
    if any(~inxValid)
        this__Error = [ 
            "Explanatory:InvalidName"
            "This name defined in an Explanatory object "
            "is not a valid Matlab name: %s"
        ];
        throw(exception.Base(this__Error, 'error'), checkList{~inxValid});
    end
end

end%

