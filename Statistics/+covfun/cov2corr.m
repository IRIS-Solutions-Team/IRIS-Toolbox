function R = cov2corr(C)
% cov2corr  Autocovariance to autocorrelation function conversion.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% The input matrix C must be ne-ne-nPer-nv where nPer is the number of
% orders or periods. Std errors will be taken from the first page in 3rd
% dimension of each parameter variant (4th dimension). Otherwise, std
% errors will be updated for each individual matrix.

%--------------------------------------------------------------------------

R = C;
realSmall = getrealsmall( );
nv = size(R, 4);
numOrders = size(R, 3);
ixDiag = eye(size(R, 1))==1;

for v = 1 : nv
    for order = 1 : numOrders
        ithR = C(:, :, order, v);
        if order==1
            invStd = diag(ithR);
            ixNonzero = abs(invStd)>realSmall;
            invStd(ixNonzero) = 1./sqrt(invStd(ixNonzero));
            D = invStd * invStd.';
        end
        indexFinite = isfinite(ithR);
        ithR(~indexFinite) = 0;
        ithR = D .* ithR;
        ithR(~indexFinite) = NaN;
        if order==1
            ithR(ixDiag) = 1;
        end
        R(:, :, order, v) = ithR;
    end
end

end
