function [inxInit, linxInit, idInit] = getInxOfInitInPresample(this, firstColumn)

numQuants = numel(this.Quantity.Name);
idInit = getIdInitialConditions(this);
row = real(idInit);
column = firstColumn + imag(idInit);
sizePresampleArray = [numQuants, firstColumn-1];
linxInit = sub2ind(sizePresampleArray, row, column);
inxInit = false(sizePresampleArray);
inxInit(linxInit) = true;

end%

