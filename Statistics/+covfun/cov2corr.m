function R = cov2corr(C)
% cov2corr  Autocovariance to autocorrelation function conversion.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% The input matrix C must be ne-ne-nPer-nAlt where nPer is the number of
% lags or periods. Std errors will be taken from the first page in 3rd
% dimension of each parameterisation. Otherwise, std errors will be updated
% for each individual matrix.

%--------------------------------------------------------------------------

R = C;
realSmall = getrealsmall( );
nAlt = size(R, 4);
ixDiag = eye(size(R,1))==1;

for iAlt = 1 : nAlt
    for iLag = 1 : size(R,3)
        Ri = C(:, :, iLag, iAlt);
        if iLag==1
            invStd = diag(Ri);
            ixNonzero = abs(invStd)>realSmall;
            invStd(ixNonzero) = 1./sqrt(invStd(ixNonzero));
            D = invStd * invStd.';
        end
        ixFinite = isfinite(Ri);
        Ri(~ixFinite) = 0;
        Ri = D .* Ri;
        Ri(~ixFinite) = NaN;
        if iLag==1
            Ri(ixDiag) = 1;
        end
        R(:, :, iLag, iAlt) = Ri;
    end
end

end