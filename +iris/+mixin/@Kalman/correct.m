function [Pe0, A0, Y0, YDelta] = correct(s, Pe0, A0, Y0, est, D)
% correct  Correct the prediction step for the estimated oolik parameters
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

delta = est(1:s.NumOutlik, :);
numExtendedPeriods = s.NumExtdPeriods;

for t = 2 : numExtendedPeriods
    j = s.yindex(:, t);
    Pe0(j, :, t) = Pe0(j, :, t) - s.M(j, :, t)*est;
end

if ~s.storePredict
    return
end

% Store the effect of out-of-lik parameters on measurement variables, 
% `ydelta`, because we need to correct k-step ahead predictions and
% smoothed estimates. The effect of diffuse init conditions, `init`, will
% have been already accounted for in the estimates of `alpha`.
ny = size(s.Z, 1);
numColumns = size(A0, 2);
YDelta = nan(ny, numColumns, numExtendedPeriods);
for t = 1 : numExtendedPeriods
    Z = s.Z(:, :, min(t, end));
    A0(:, :, t) = A0(:, :, t) + s.Q{t}*est;
    YDelta(:, :, t) = s.X(:, :, t)*delta;
    Y0(:, :, t) = Z*A0(:, :, t, 1) + YDelta(:, :, t);
    if ~isempty(D)
        Y0(:, :, t) = Y0(:, :, t) + D(:, min(t, end));
    end
end

end%

