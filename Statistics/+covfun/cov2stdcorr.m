function vecStdCorr = cov2stdcorr(omg, varargin)
% cov2stdcorr  Convert covariance matrix to stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Permute ne-ne-nPer-nAlt to ne-ne-1-nPer*nAlt.
[~, ne, nPer, nAlt] = size(omg);
omg = permute(omg(:, :, :), [1, 2, 4, 3]);
n = nPer*nAlt;

ixTrill = tril(ones(ne), -1)==1;
R = covfun.cov2corr(omg);
nStdCorr = ne + ne*(ne-1)/2;
vecStdCorr = nan(nStdCorr, n);
for i = 1 : n
    vecStdCorr(1:ne, i) = sqrt( diag(omg(:, :, 1, i)) );
    vecStdCorr(ne+1:end, i) = R(ixTrill);
end
vecStdCorr = reshape(vecStdCorr, [nStdCorr, nPer, nAlt]);

end
