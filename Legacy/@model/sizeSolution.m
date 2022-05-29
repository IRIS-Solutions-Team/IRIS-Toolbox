% sizeSolution  Size of solution vectors
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [ny, nxi, nb, nf, ne, ng, nz, numV, numW] = sizeSolution(this)

[ny, nxi, nb, nf, ne, ng] = sizeSolution(this.Vector);
if nargout<=6
    return
end

nz = nnz(this.Quantity.IxObserved);
if nargout<=7
    return
end

numV = nnz(this.Quantity.Type==32);
numW = nnz(this.Quantity.Type==31);

end%

