function [inxOfInit, linxOfInit, idOfInit] = getInxOfInitInPresample(this, firstColumn)
% getInxOfInitInPresample  Get index of initial conditions in presample data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

numOfQuants = numel(this.Quantity.Name);
idOfInit = getIdOfInitialConditions(this);
row = real(idOfInit);
column = firstColumn + imag(idOfInit);
sizeOfPresampleArray = [numOfQuants, firstColumn-1];
linxOfInit = sub2ind(sizeOfPresampleArray, row, column);
inxOfInit = false(sizeOfPresampleArray);
inxOfInit(linxOfInit) = true;

end%

