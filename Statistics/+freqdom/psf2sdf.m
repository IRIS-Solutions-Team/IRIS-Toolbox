function D = psf2sdf(S, C)
% psf2sdf  Convert power spectrum to spectral density.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

D = S;
realSmall = getrealsmall( );
nv = size(S, 4);
for v = 1 : nv
   Dk = S(:, :, :, v);
   aux = diag(C(:, :, 1, v));
   indexNonzero = abs(aux)>realSmall;
   aux(indexNonzero) = 1./sqrt(aux(indexNonzero));
   X = aux(:, ones([1, size(aux, 1)]));
   X = X .* transpose(X);
   indexInf = isinf(Dk(:, :, :));
   Dk(indexInf) = 0;
   for i = 1 : size(Dk, 3)
      Dk(:, :, i) = X .* Dk(:, :, i);
   end
   Dk(indexInf) = NaN;
   D(:, :, :, v) = Dk;
end

end
