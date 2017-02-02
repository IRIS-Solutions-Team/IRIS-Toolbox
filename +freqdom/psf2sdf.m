function D = psf2sdf(S,C)
% psf2sdf  Convert power spectrum to spectral density.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%**************************************************************************

D = S;
realSmall = getrealsmall( );
nAlt = size(S,4);

for iAlt = 1 : nAlt
   Dk = S(:,:,:,iAlt);
   aux = diag(C(:,:,1,iAlt));
   nonZero = abs(aux) > realSmall;
   aux(nonZero) = 1./sqrt(aux(nonZero));
   X = aux(:,ones([1,size(aux,1)]));
   X = X.*transpose(X);
   index = isinf(Dk(:,:,:));
   Dk(index) = 0;
   for i = 1 : size(Dk,3)
      Dk(:,:,i) = X.*Dk(:,:,i);
   end
   Dk(index) = NaN;
   D(:,:,:,iAlt) = Dk;
end

end
