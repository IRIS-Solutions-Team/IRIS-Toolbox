function checkInitialCondition(this, inxOfNaNYXEPG, firstColumn)
% checkInitialCondition  Look up initial conditions missing from input databank

[~, linxOfInit, idOfInit] = getInxOfInitInPresample(this, firstColumn);
inxOfNaNInit = inxOfNaNYXEPG(linxOfInit);

if any(inxOfNaNInit)
    THIS_ERROR = { 'Model:MissingInitialCondition'
                   'This initial condition is missing from input databank: %s ' };
    logStyle = '';
    listOfNaNInit = printSolutionVector(this, idOfInit(inxOfNaNInit), logStyle);
    throw( exception.Base(THIS_ERROR, 'error'), ...
           listOfNaNInit{:} );
end    

end%

