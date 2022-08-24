function [X, inxLog, allNames] = createTrendArray(this, variantsRequested, needsDelog, id, vecTime)

nv = countVariants(this);

try, variantsRequested;
    catch, variantsRequested = @all; end

try, needsDelog;
    catch, needsDelog = true; end

try, id;
    catch, id = @all; end

try, vecTime;
    catch, vecTime = this.Incidence.Dynamic.Shift; end

%--------------------------------------------------------------------------

if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
end

if isequal(id, @all)
    id = 1 : numel(this.Quantity.Name);
end

posTrendLine = locateTrendLine(this.Quantity, NaN);
vecTime = reshape(vecTime, 1, [ ]);
numPeriods = numel(vecTime);
numVariantsRequested = numel(variantsRequested);
variantsRequested(variantsRequested>nv) = nv;

posQuantity = real(id);

inxLog = this.Quantity.IxLog(posQuantity);
anyLog = any(inxLog);
inxLog3d = repmat(inxLog, 1, 1, numVariantsRequested);

levelX = real(this.Variant.Values(1, posQuantity, variantsRequested));
changeX = imag(this.Variant.Values(1, posQuantity, variantsRequested));

%
% Time trend is handled separately so that the steady change part is not created
% unless some non-time-trend quantity requires that
%
posTtrendWithin = find(posQuantity==posTrendLine);
anyTtrend = ~isempty(posTrendLine);
if anyTtrend
    changeX(:, posTtrendWithin, :) = 0;
end

% Zero or no imag means zero change also for log variables
if anyLog
    inxReset = inxLog3d & changeX==0;
    if any(inxReset)
        changeX(inxReset) = 1;
    end
    levelX(inxLog3d) = reallog(levelX(inxLog3d));
end

levelX = permute(levelX, [2, 1, 3]);
X = repmat(levelX, 1, numPeriods, 1);

inxChange3d = (inxLog3d & changeX~=1) | (~inxLog3d & changeX~=0);
anyChange = any(inxChange3d(:));
if anyChange
    %
    % Create a time vector for each quantity, shifted by the lag or lead of
    % that quantity
    %
    vecTimeShifted = vecTime + reshape(imag(id), [ ], 1);
    vecTimeShifted = repmat(vecTimeShifted, 1, 1, numVariantsRequested);

    inx = inxLog3d & inxChange3d;
    changeX(inx) = reallog(changeX(inx));

%     if anyLog
%         inx = inxLog3d & inxChange3d;
%         if any(inx)
%             changeX(inx) = reallog(changeX(inx));
%         end
%     end

    changeX = repmat(permute(changeX, [2, 1, 3]), 1, numPeriods, 1);
    inxChange3d = repmat(permute(inxChange3d, [2, 1, 3]), 1, numPeriods, 1);
    % X(q, t, v) = X(q, t, v) + changeX(q, 1, v) * vecTimeShifted(q, t)
    X(inxChange3d) = X(inxChange3d) + changeX(inxChange3d) .* vecTimeShifted(inxChange3d);
end

% Delogarithmize only if requested
if needsDelog && anyLog
    X(inxLog, :, :) = real(exp(X(inxLog, :, :)));
end

% Populate time trend
if anyTtrend
    X(posTtrendWithin, :, :) = repmat(vecTime, numel(posTtrendWithin), 1, numVariantsRequested);
end

if nargout>=3
    allNames = string(this.Quantity.Name);
end

end%

