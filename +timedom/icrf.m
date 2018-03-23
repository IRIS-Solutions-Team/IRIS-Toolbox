function [xi, sizeOfDeviation] = icrf(T, ~, ~, Z, ~, ~, U, ~, nPer, sizeOfDeviation)
% icrf  Response function to initial condition for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(Z, 1);
[nxi, nb] = size(T);
nf = nxi - nb;

xi = zeros(ny+nxi, nb, nPer+1);
xi(ny+nf+1:end, :, 1) = diag(sizeOfDeviation);
if ~isempty(U)
   xi(ny+nf+1:end, :, 1) = U\xi(ny+nf+1:end, :, 1);
end

for t = 2 : nPer + 1
   xi(ny+1:end, :, t) = T*xi(ny+nf+1:end, :, t-1);
   if ny>0
      xi(1:ny, :, t) = Z*xi(ny+nf+1:end, :, t);
   end
end

if ~isempty(U)
   for t = 1 : nPer+1
      xi(ny+nf+1:end, :, t) = U*xi(ny+nf+1:end, :, t);
   end
end

end
