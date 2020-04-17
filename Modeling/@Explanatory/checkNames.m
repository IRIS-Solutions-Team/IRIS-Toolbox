function checkNames(this)
% checkNames  Check all names in Explanatory array for multiple occurrencies
%{
% Backend [IrisToolbox] method
% No help provided
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

checkList = [this.VariableNames, this.ControlNames];
if isfinite(this.PosLhsName)
    checkList = [checkList, this.ResidualName, this.FittedName];
end

%
% Find multiple occurrences of the same name including ResidualName,
% FittedName and ControlName
%
nameConflicts = parser.getMultiple(checkList);
if ~isempty(nameConflicts)
    nameConflicts = cellstr(nameConflicts);
    thisError = [ 
        "Explanatory:MultipleNames"
        "This name is declared more than once in an Explanatory object "
        "(including ResidualName, FittedName and ControlNames): %s "
    ];
    throw( exception.Base(thisError, 'error'), ...
           nameConflicts{:} );
end

%
% Make sure all names are valid Matlab names
%
inxValid = arrayfun(@isvarname, checkList);
if any(~inxValid)
    thisError = [ 
        "Explanatory:InvalidName"
        "This name defined in an Explanatory object "
        "is not a valid Matlab name: %s"
    ];
    throw(exception.Base(thisError, 'error'), checkList{~inxValid});
end

end%

