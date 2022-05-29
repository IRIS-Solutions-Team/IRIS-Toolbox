function CC = xsf2acf(SS, freq, maxOrder)
% xsf2acf  Convert power spectrum to autocovariances.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

numFreq = length(freq);
nx = size(SS, 1);
CC = zeros(nx, nx, maxOrder+1);
for i = 1 : numFreq
    ithFreq = freq(i);
    s = SS(:, :, i);
    CC(:, :, 1) = CC(:, :, 1) + s;
    for k = 1 : maxOrder
        CC(:, :, 1+k) = CC(:, :, 1+k) + s*exp(1i*ithFreq*k);
    end
end
% We should multiply by 2*width == 2*pi/numFreq but we skip
% dividing SS by 2*pi in XSF and hence skip multiplying it by
% 2*pi here.
CC = real(CC) / numFreq;
CC(isinf(CC)) = NaN;

end
