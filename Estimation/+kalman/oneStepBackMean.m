function [Y2, F2, B2, E2, r, A2] = oneStepBackMean(s, time, Pe, A0, F0, YDelta, D, r)
% oneStepBackMean  One-step backward smoothing for point estimates
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = size(s.Z, 1);
nf = size(s.Tf, 1);
ne = size(s.Ra, 2);
numOfPOut = s.NPOut;
inxOfET = s.InxOfET; % Transition shocks.
inxOfEM = s.InxOfEM; % Measurement shocks.
Ra = s.Ra(:, 1:ne);
Omg = s.Omg(:, :, min(time, end));

inxOfObs = s.yindex(:, time);
Fipe = s.FF(inxOfObs, inxOfObs, time) \ Pe(inxOfObs, :);

numOfColumns = size(Pe, 2);
Y2 = nan(ny, numOfColumns);
E2 = zeros(ne, numOfColumns);
F2 = zeros(nf, numOfColumns);

isRZero = all(r(:) == 0);

% Measurement shocks.
if any(inxOfObs)
    K0 = s.Ta*s.K1(:, inxOfObs, time);
    HOmg = s.H(inxOfObs, inxOfEM) * Omg(inxOfEM, :);
    if isRZero
        E2 = E2 + HOmg.' * Fipe;
    else
        E2 = E2 + HOmg.' * (Fipe - K0.'*r);
    end
end

% Update `r`.
if isRZero
    r = s.Zt(:, inxOfObs)*Fipe;
else
    r = s.Zt(:, inxOfObs)*Fipe + s.L(:, :, time).'*r;
end

% Transition variables.
A2 = A0 + s.Pa0(:, :, time)*r;
if nf>0
    F2 = F0 + s.Pfa0(:, :, time)*r;
end
B2 = s.U*A2;

% Transition shocks.
RaOmg = Ra(:, inxOfET)*Omg(inxOfET, :);
E2 = E2 + RaOmg.'*r;

% Back out NaN measurement variables.
if any(~inxOfObs)
    Y2(~inxOfObs, :) = s.Z(~inxOfObs, :)*A2 + s.H(~inxOfObs, :)*E2;
    if numOfPOut>0
        % Correct the estimates of NaN observations for the effect of estimated
        % out-of-lik parameters.
        Y2(~inxOfObs, :) = Y2(~inxOfObs, :) + YDelta(~inxOfObs, :);
    end
    if ~isempty(D)
        % Correct the estimates of NaN observations for deterministic trends.
        Y2(~inxOfObs, 1) = Y2(~inxOfObs, 1) + D(~inxOfObs, :);
    end
end
    
end%

