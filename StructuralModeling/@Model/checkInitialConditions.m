function checkInitialCondition(this, inxNaNYXEPG, firstColumn)

%--------------------------------------------------------------------------

[~, linxInit, idInit] = getInxOfInitInPresample(this, firstColumn);
inxNaNInit = inxNaNYXEPG(linxInit);
%T = this.Variant.FirstOrderSolution{1};
%inxZero = all(T==0, 1);

if any(inxNaNInit)
    thisError = [
        "Model:MissingInitialCondition"
        "This initial condition is missing from input databank: %s "
    ];
    logStyle = '';
    listNaNInit = printSolutionVector(this, idInit(inxNaNInit), logStyle);
    throw(exception.Base(thisError, 'error'), listNaNInit{:});
end    

end%

