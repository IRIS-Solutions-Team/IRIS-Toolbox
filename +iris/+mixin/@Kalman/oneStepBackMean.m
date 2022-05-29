function [Y2, F2, B2, E2, r, A2] = oneStepBackMean(s, time, Pe, A0, F0, YDelta, D, r)
% oneStepBackMean  One-step backward smoothing for point estimates
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = s.NumY;
nf = s.NumF;
ne = s.NumE;
inxV = s.InxV; % Transition shocks
inxW = s.InxW; % Measurement shocks
Ra = s.Ra(:, :, min(time, end));
Z = s.Z(:, :, min(time, end));
H = s.H(:, :, min(time, end));
if isempty(s.U)
    U = [ ];
else
    U = s.U(:, :, min(time, end));
end
Omg = s.Omg(:, :, min(time, end));

inxObs = s.yindex(:, time);
Fipe = s.FF(inxObs, inxObs, time) \ Pe(inxObs, :);

numColumns = size(Pe, 2);
Y2 = nan(ny, numColumns);
E2 = zeros(ne, numColumns);
F2 = zeros(nf, numColumns);

isRZero = all(r(:) == 0);

% Measurement shocks
if any(inxObs)
    HOmg = H(inxObs, inxW) * Omg(inxW, :);
    if isRZero
        E2 = E2 + HOmg' * Fipe;
    else
        K0 = s.K0(:, inxObs, time);
        E2 = E2 + HOmg' * (Fipe - K0'*r);
    end
end

% Update `r`
if isRZero
    r = transpose(Z(inxObs, :))*Fipe;
else
    r = transpose(Z(inxObs, :))*Fipe + transpose(s.L(:, :, time))*r;
end

% Transition variables
A2 = A0 + s.Pa0(:, :, time)*r;
if nf>0
    F2 = F0 + s.Pfa0(:, :, time)*r;
end
if isempty(U)
    B2 = A2;
else
    B2 = U*A2;
end

% Transition shocks
RaOmg = Ra(:, inxV)*Omg(inxV, :);
E2 = E2 + RaOmg.'*r;

% Back out NaN measurement variables
if any(~inxObs)
    Y2(~inxObs, :) = Z(~inxObs, :)*A2 + H(~inxObs, :)*E2;
    if s.NumOutlik>0
        % Correct the estimates of NaN observations for the effect of estimated
        % out-of-lik parameters
        Y2(~inxObs, :) = Y2(~inxObs, :) + YDelta(~inxObs, :);
    end
    if ~isempty(D)
        % Correct the estimates of NaN observations for deterministic trends
        Y2(~inxObs, 1) = Y2(~inxObs, 1) + D(~inxObs, :);
    end
end
    
end%

