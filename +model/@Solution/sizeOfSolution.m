function [ny, nxi, nb, nf, ne] = sizeOfSolution(this)
% sizeOfSolution  Size of solution matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(this.Z, 1);
[nxi, nb] = size(this.T);
nf = nxi - nb;
ne = size(this.H, 2);

end
