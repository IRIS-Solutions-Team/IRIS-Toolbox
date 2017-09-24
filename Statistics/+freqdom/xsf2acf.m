function C = xsf2acf(S,freq,order)
% XSF2ACF  [Not a public function] Convert power spectrum to autocovariances.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%**************************************************************************

nfreq = length(freq);
nx = size(S,1);
C = zeros(nx,nx,order+1);
for i = 1 : nfreq
    s = S(:,:,i);
    C(:,:,1) = C(:,:,1) + s;
    for k = 1 : order
        C(:,:,1+k) = C(:,:,1+k) + s*exp(1i*freq(i)*k);
    end
end
% We should multiply by 2*width == 2*pi/nfreq but we skip
% dividing S by 2*pi in XSF and hence skip multiplying it by
% 2*pi here.
C = real(C) / nfreq;
C(isinf(C)) = NaN;

end