function [ny, nxi, nb, nf, ne, ng, nz] = sizeOfSolution(this)
% sizeOfSolution  Size of solution vectors.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this.Vector);
if nargout>6
    nz = nnz(this.Quantity.ixMeasure);
end

end
