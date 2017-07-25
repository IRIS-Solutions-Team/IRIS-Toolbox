function [YXEPG, L] = lp4yxe(this, YXEPG, vecAlt, howToCreateL)

TYPE = @int8;

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixp = this.Quantity.Type==TYPE(4);
nXPer = size(YXEPG, 2);
nData = size(YXEPG, 3);
nVecAlt = length(vecAlt);

if nargout>1
needsDelog = true;
posyx = find(ixy | ixx);
if isequal(howToCreateL, Inf)
    L = YXEPG(posyx, :, :);
else
    ixTtrend = strcmp(this.Quantity.Name, model.RESERVED_NAME_TTREND);
    ttrend = YXEPG(ixTtrend, :, 1);
    L = createTrendArray(this, vecAlt, needsDelog, posyx, ttrend);
end
end

P = model.Variant.getQuantity(this.Variant, ixp, vecAlt);
P = permute(P, [2, 1, 3]);
P = repmat(P, 1, nXPer, 1);
if nData>nVecAlt && nVecAlt==1
    P = repmat(P, 1, 1, nData);
    if nargout>1
        L = repmat(L, 1, 1, nData);
    end
elseif nVecAlt>nData && nData==1
    YXEPG = repmat(YXEPG, 1, 1, nVecAlt);
elseif nVecAlt~=nData
    throw( ...
        exception.Base('Model:InconsistentParamData', 'error'), ...
        nVecAlt, nData ...
        ); %#ok<GTARG>
end
YXEPG(ixp, :, :) = P;

end
