function [Y2, F2, B2, E2, r, A2] = oneStepBackMean(s, time, Pe, A0, F0, YDelta, D, r)
% oneStepBackMean  One-step backward smoothing for point estimates.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(s.Z, 1);
nf = size(s.Tf, 1);
ne = size(s.Ra, 2);
nPOut = s.NPOut;
ixet = s.IxEt; % Transition shocks.
ixem = s.IxEm; % Measurement shocks.
Ra = s.Ra(:, 1:ne);
Omg = s.Omg(:, :, min(time, end));

jy = s.yindex(:, time);
Fipe = s.FF(jy, jy, time) \ Pe(jy, :);

nCol = size(Pe, 2);
Y2 = nan(ny, nCol);
E2 = zeros(ne, nCol);
F2 = zeros(nf, nCol);

isRZero = all(r(:) == 0);

% Measurement shocks.
if any(jy)
    K0 = s.Ta*s.K1(:, jy, time);
    HOmg = s.H(jy, ixem)*Omg(ixem, :);
    if isRZero
        E2 = E2 + HOmg.'*Fipe;
    else
        E2 = E2 + HOmg.'*(Fipe - K0.'*r);
    end
end

% Update `r`.
if isRZero
    r = s.Zt(:, jy)*Fipe;
else
    r = s.Zt(:, jy)*Fipe + s.L(:, :, time).'*r;
end

% Transition variables.
A2 = A0 + s.Pa0(:, :, time)*r;
if nf > 0
    F2 = F0 + s.Pfa0(:, :, time)*r;
end
B2 = s.U*A2;

% Transition shocks.
RaOmg = Ra(:, ixet)*Omg(ixet, :);
E2 = E2 + RaOmg.'*r;

% Back out NaN measurement variables.
if any(~jy)
    Y2(~jy, :) = s.Z(~jy, :)*A2 + s.H(~jy, :)*E2;
    if nPOut > 0
        % Correct the estimates of NaN observations for the effect of estimated
        % out-of-lik parameters.
        Y2(~jy, :) = Y2(~jy, :) + YDelta(~jy, :);
    end
    if ~isempty(D)
        % Correct the estimates of NaN observations for deterministic trends.
        Y2(~jy, 1) = Y2(~jy, 1) + D(~jy, :);
    end
end
    
end
