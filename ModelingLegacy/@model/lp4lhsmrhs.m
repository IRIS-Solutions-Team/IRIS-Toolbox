function [YXEPG, L] = lp4lhsmrhs(this, YXEPG, variantsRequested, howToCreateL)
% lp4lhsmrhs  Fill in parameters and steady trends in YXEPG data matrix
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

nv = countVariants(this);
inxP = getIndexByType(this.Quantity, TYPE(4));
numExtendedPeriods = size(YXEPG, 2);
numDataSets = size(YXEPG, 3);

if isequal(variantsRequested, @all) || isequal(variantsRequested, Inf)
    variantsRequested = 1 : nv;
end
numVariantsRequested = numel(variantsRequested);

if nargout>1
    needsDelog = true;
    inxYX = getIndexByType(this.Quantity, TYPE(1), TYPE(2));
    posYX = find(inxYX);
    if isequal(howToCreateL, Inf)
        % Take steady trends from data matrix
        L = YXEPG(posYX, :, :);
    else
        % Create steady trends from model
        inxTimeTrend = strcmp(this.Quantity.Name, model.component.Quantity.RESERVED_NAME_TTREND);
        timeTrend = YXEPG(inxTimeTrend, :, 1);
        L = createTrendArray(this, variantsRequested, needsDelog, posYX, timeTrend);
    end
end

P = this.Variant.Values(:, inxP, variantsRequested);
P = permute(P, [2, 1, 3]);
P = repmat(P, 1, numExtendedPeriods, 1);
if numDataSets>numVariantsRequested && numVariantsRequested==1
    P = repmat(P, 1, 1, numDataSets);
    if nargout>1
        L = repmat(L, 1, 1, numDataSets);
    end
elseif numVariantsRequested>numDataSets && numDataSets==1
    YXEPG = repmat(YXEPG, 1, 1, numVariantsRequested);
elseif numVariantsRequested~=numDataSets
    throw( ...
        exception.Base('Model:InconsistentParamData', 'error'), ...
        numVariantsRequested, numDataSets ...
    );
end
YXEPG(inxP, :, :) = P;

end%

