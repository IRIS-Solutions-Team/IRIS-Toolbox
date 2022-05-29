function D = cov2var(P,varargin)
% cov2var  [Not a public function] Retrieve diagonal elements (variances) from a sequence of covariance matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

pSize = size(P);
D = nan(pSize([1,3:end]));
for i = 1 : pSize(1)
    D(i,:,:) = P(i,i,:,:);
end

end
