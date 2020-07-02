% sizeOfSolution  Size of solution vectors
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [ny, nxi, nb, nf, ne, ng, nz, numV, numW] = sizeOfSolution(this)

%--------------------------------------------------------------------------

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this.Vector);
if nargout<=6
    return
end

nz = nnz(this.Quantity.IxObserved);
if nargout<=7
    return
end

TYPE = @int8;
numV = nnz(this.Quantity.Type==TYPE(32));
numW = nnz(this.Quantity.Type==TYPE(31));

end%

