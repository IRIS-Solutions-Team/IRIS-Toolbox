function checkNames(this)
% checkNames  Check all names in ExplanatoryEquation array for multiple occurrencies
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

checkList = this.VariableNames;
if isfinite(this.PosOfLhsName)
    checkList = [checkList, this.ResidualName];
end
nameConflicts = parser.getMultiple(checkList);
if ~isempty(nameConflicts)
    nameConflicts = cellstr(nameConflicts);
    thisError = [ 
        "ExplanatoryEquation:MultipleNames"
        "This name is declared more than once in an ExplanatoryEquation object "
        "(including ResidualName and FittedName): %s "
    ];
    throw( exception.Base(thisError, 'error'), ...
           nameConflicts{:} );
end
inxValid = arrayfun(@isvarname, checkList);
if any(~inxValid)
    thisError = [ 
        "ExplanatoryEquation:InvalidName"
        "This name defined in an ExplanatoryEquation object "
        "is not a valid Matlab name: %s"
    ];
    throw(exception.Base(thisError, 'error'), checkList{~inxValid});
end

end%

