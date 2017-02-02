function vecStdCorr = cov2stdcorr(Omg,varargin)
% cov2stdcorr  [Not a public function] Convert cov matrix to stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Permute ne-ne-nPer-nAlt to ne-ne-1-nPer*nAlt.
[~, ne, nPer, nAlt] = size(Omg);
Omg = permute(Omg(:,:,:), [1,2,4,3]);
n = nPer*nAlt;

ixCorr = tril(ones(ne), -1)==1;
R = covfun.cov2corr(Omg);
nStdCorr = ne + ne*(ne-1)/2;
vecStdCorr = nan(nStdCorr, n);
for i = 1 : n
    vecStdCorr(1:ne, i) = sqrt( diag(Omg(:, :, 1, i)) );
    vecStdCorr(ne+1:end, i) = R(ixCorr);
end
vecStdCorr = reshape(vecStdCorr, [nStdCorr, nPer, nAlt]);

end
