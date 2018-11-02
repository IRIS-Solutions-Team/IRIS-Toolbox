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
inxET = s.InxEt; % Transition shocks.
inxEM = s.InxEM; % Measurement shocks.
Ra = s.Ra(:, 1:ne);
Omg = s.Omg(:, :, min(time, end));

inxY = s.yindex(:, time);
Fipe = s.FF(inxY, inxY, time) \ Pe(inxY, :);

nCol = size(Pe, 2);
Y2 = nan(ny, nCol);
E2 = zeros(ne, nCol);
F2 = zeros(nf, nCol);

isRZero = all(r(:) == 0);

% Measurement shocks.
if any(inxY)
    K0 = s.Ta*s.K1(:, inxY, time);
    HOmg = s.H(inxY, inxEM) * Omg(inxEM, :);
    if isRZero
        E2 = E2 + HOmg.' * Fipe;
    else
        E2 = E2 + HOmg.' * (Fipe - K0.'*r);
    end
end

% Update `r`.
if isRZero
    r = s.Zt(:, inxY)*Fipe;
else
    r = s.Zt(:, inxY)*Fipe + s.L(:, :, time).'*r;
end

% Transition variables.
A2 = A0 + s.Pa0(:, :, time)*r;
if nf > 0
    F2 = F0 + s.Pfa0(:, :, time)*r;
end
B2 = s.U*A2;

% Transition shocks.
RaOmg = Ra(:, inxET)*Omg(inxET, :);
E2 = E2 + RaOmg.'*r;

% Back out NaN measurement variables.
if any(~inxY)
    Y2(~inxY, :) = s.Z(~inxY, :)*A2 + s.H(~inxY, :)*E2;
    if numOfPOut > 0
        % Correct the estimates of NaN observations for the effect of estimated
        % out-of-lik parameters.
        Y2(~inxY, :) = Y2(~inxY, :) + YDelta(~inxY, :);
    end
    if ~isempty(D)
        % Correct the estimates of NaN observations for deterministic trends.
        Y2(~inxY, 1) = Y2(~inxY, 1) + D(~inxY, :);
    end
end
    
end%

