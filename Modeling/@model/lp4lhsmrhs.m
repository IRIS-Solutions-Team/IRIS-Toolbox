function [YXEPG, L] = lp4lhsmrhs(this, YXEPG, variantsRequested, howToCreateL)

TYPE = @int8;

nv = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixp = this.Quantity.Type==TYPE(4);
numOfExtendedPeriods = size(YXEPG, 2);
numOfDataSets = size(YXEPG, 3);

if isequal(variantsRequested, @all) || isequal(variantsRequested, Inf)
    variantsRequested = 1 : nv;
end
numOfVariantsRequested = numel(variantsRequested);

if nargout>1
    needsDelog = true;
    posyx = find(ixy | ixx);
    if isequal(howToCreateL, Inf)
        L = YXEPG(posyx, :, :);
    else
        inxOfTimeTrend = strcmp(this.Quantity.Name, model.RESERVED_NAME_TTREND);
        timeTrend = YXEPG(inxOfTimeTrend, :, 1);
        L = createTrendArray(this, variantsRequested, needsDelog, posyx, timeTrend);
    end
end

P = this.Variant.Values(:, ixp, variantsRequested);
P = permute(P, [2, 1, 3]);
P = repmat(P, 1, numOfExtendedPeriods, 1);
if numOfDataSets>numOfVariantsRequested && numOfVariantsRequested==1
    P = repmat(P, 1, 1, numOfDataSets);
    if nargout>1
        L = repmat(L, 1, 1, numOfDataSets);
    end
elseif numOfVariantsRequested>numOfDataSets && numOfDataSets==1
    YXEPG = repmat(YXEPG, 1, 1, numOfVariantsRequested);
elseif numOfVariantsRequested~=numOfDataSets
    throw( exception.Base('Model:InconsistentParamData', 'error'), ...
           numOfVariantsRequested, numOfDataSets );
end
YXEPG(ixp, :, :) = P;

end%

