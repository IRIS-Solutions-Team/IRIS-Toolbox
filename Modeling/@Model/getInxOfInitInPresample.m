function [inxInit, linxInit, idInit] = getInxOfInitInPresample(this, firstColumn)
% getInxOfInitInPresample  Get index of initial conditions in presample data
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numQuants = numel(this.Quantity.Name);
idInit = getIdOfInitialConditions(this);
row = real(idInit);
column = firstColumn + imag(idInit);
sizePresampleArray = [numQuants, firstColumn-1];
linxInit = sub2ind(sizePresampleArray, row, column);
inxInit = false(sizePresampleArray);
inxInit(linxInit) = true;

end%

