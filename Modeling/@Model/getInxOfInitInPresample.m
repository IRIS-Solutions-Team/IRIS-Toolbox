function [inxOfInit, linxOfInit, idOfInit] = getInxOfInitInPresample(this, firstColumn)
    numOfQuants = numel(this.Quantity.Name);
    idOfInit = getIdOfInitialConditions(this);
    row = real(idOfInit);
    column = firstColumn + imag(idOfInit);
    sizeOfPresampleArray = [numOfQuants, firstColumn-1];
    linxOfInit = sub2ind(sizeOfPresampleArray, row, column);
    inxOfInit = false(sizeOfPresampleArray);
    inxOfInit(linxOfInit) = true;
end%

