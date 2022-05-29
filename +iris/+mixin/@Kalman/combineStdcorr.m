% combineStdcorr  Combine baseline stdcorr with user supplied overrides and multipliers
% 
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function sx = combineStdcorr(baselineStdcorr, override, multiply, numPeriods)

%
% No user supplied overrides or multipliers, return model stdcorr
% immediately
% 
if isempty(override) && isempty(multiply)
    sx = baselineStdcorr;
    return
end

hereCheckDimensions( );

%
% Combine user supplied overrides and multipliers with model stdcorr
%
numPeriodsOverride = size(override, 2);
numPeriodsMultiply = size(multiply, 2);
numPeriodsThisStdcorr = size(baselineStdcorr, 2);
last = max([numPeriodsThisStdcorr, numPeriodsOverride, numPeriodsMultiply]);
if numPeriodsOverride<last
    override(:, end+1:last) = NaN;
end
if numPeriodsMultiply<last
    multiply(:, end+1:last) = NaN;
end
sx = baselineStdcorr;
if numPeriodsThisStdcorr<last
    sx = [sx, repmat(sx(:, end), 1, last-numPeriodsThisStdcorr)];
end
inxMultiply = ~isnan(multiply);
if any(inxMultiply(:))
    ne = size(multiply, 1);
    temp = sx(1:ne, :);
    temp(inxMultiply) = temp(inxMultiply) .* multiply(inxMultiply);
    sx(1:ne, :) = temp;
end
inxOverride = ~isnan(override);
if any(inxOverride(:))
    sx(inxOverride) = override(inxOverride);
end

%
% Add model stdcorr if the last user-supplied data point is before
% the end of the sample
%
if size(sx, 2)<numPeriods
    sx = [sx, baselineStdcorr(:, end)];
end

return

    function hereCheckDimensions( )
        if size(override, 3)>1 || size(multiply, 3)>1
            thisError = { 'Kalman:MultipleStdcorrOverrideOrMultipliers'
                          'Only one set of std and corr overrides and multipliers is allowed' };
            throw(exception.Base(thisError, 'error'));
        end
    end%
end%

