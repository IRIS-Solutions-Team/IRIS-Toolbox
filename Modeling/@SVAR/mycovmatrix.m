function structuralCov = mycovmatrix(this, variantsRequested)
% mycovmatrix  Covariance matrix of structural residuals
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if nargin<2 || (~isnumeric(variantsRequested) && isequal(variantsRequested, ':')) 
    variantsRequested = 1 : size(this.A, 3);
else
    variantsRequested = transpose(variantsRequested(:));
end

%--------------------------------------------------------------------------

ny = size(this.A, 1);
numVariantsRequested = numel(variantsRequested);

varVec = this.Std(1, variantsRequested) .^ 2;
varVec = permute(varVec(:), [2, 3, 1]);

q = min(ny, this.Rank(1, variantsRequested));
structuralCov = repmat(eye(ny), 1, 1, numVariantsRequested);
for i = 1 : numVariantsRequested
    structuralCov(:, q(i)+1:end, i) = 0;
end
structuralCov = bsxfun(@times, structuralCov, varVec);

end%

