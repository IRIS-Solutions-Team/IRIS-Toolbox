function [YXEPG, L] = lp4lhsmrhs(this, YXEPG, variantsRequested, howToCreateL)
% lp4lhsmrhs  Fill in parameters and steady trends in YXEPG data matrix
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

nv = length(this);
inxOfP = getIndexByType(this.Quantity, TYPE(4));
numOfExtendedPeriods = size(YXEPG, 2);
numOfDataSets = size(YXEPG, 3);

if isequal(variantsRequested, @all) || isequal(variantsRequested, Inf)
    variantsRequested = 1 : nv;
end
numOfVariantsRequested = numel(variantsRequested);

if nargout>1
    needsDelog = true;
    inxOfYX = getIndexByType(this.Quantity, TYPE(1), TYPE(2));
    posOfYX = find(inxOfYX);
    if isequal(howToCreateL, Inf)
        % Take steady trends from data matrix
        L = YXEPG(posOfYX, :, :);
    else
        % Create steady trends from model
        inxOfTimeTrend = strcmp(this.Quantity.Name, model.RESERVED_NAME_TTREND);
        timeTrend = YXEPG(inxOfTimeTrend, :, 1);
        L = createTrendArray(this, variantsRequested, needsDelog, posOfYX, timeTrend);
    end
end

P = this.Variant.Values(:, inxOfP, variantsRequested);
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
YXEPG(inxOfP, :, :) = P;

end%

