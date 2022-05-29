% cov2stdcorr  Convert covariance matrix to stdcorr vector
%
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function vecStdCorr = cov2stdcorr(omg, stdOnly)

if nargin<2
    stdOnly = false;
end

% Permute ne-ne-nPer-nAlt to ne-ne-1-nPer*nAlt
[~, ne, nPer, nAlt] = size(omg);
omg = permute(omg(:, :, :), [1, 2, 4, 3]);
n = nPer*nAlt;

nStdCorr = ne;
if ~stdOnly
    nStdCorr = nStdCorr + ne*(ne-1)/2;
    ixTrill = tril(ones(ne), -1)==1;
    R = covfun.cov2corr(omg);
end

vecStdCorr = nan(nStdCorr, n);
for i = 1 : n
    vecStdCorr(1:ne, i) = sqrt( diag(omg(:, :, 1, i)) );
    if ~stdOnly
        vecStdCorr(ne+1:end, i) = R(ixTrill);
    end
end

vecStdCorr = reshape(vecStdCorr, [nStdCorr, nPer, nAlt]);

end
