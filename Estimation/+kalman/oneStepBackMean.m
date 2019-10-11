function [Y2, F2, B2, E2, r, A2] = oneStepBackMean(s, time, Pe, A0, F0, YDelta, D, r)
% oneStepBackMean  One-step backward smoothing for point estimates
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = size(s.Z, 1);
nf = size(s.Tf, 1);
ne = size(s.Ra, 2);
numPOut = s.NPOut;
inxET = s.InxOfET; % Transition shocks.
inxEM = s.InxOfEM; % Measurement shocks.
Ra = s.Ra(:, 1:ne);
Omg = s.Omg(:, :, min(time, end));

inxObs = s.yindex(:, time);
Fipe = s.FF(inxObs, inxObs, time) \ Pe(inxObs, :);

numColumns = size(Pe, 2);
Y2 = nan(ny, numColumns);
E2 = zeros(ne, numColumns);
F2 = zeros(nf, numColumns);

isRZero = all(r(:) == 0);

% Measurement shocks.
if any(inxObs)
    %
    % K0(t+1<-t) = Ta(t+1<-t)*K1(t)
    %
    K0 = s.Ta*s.K1(:, inxObs, time);
    % TODO: K0 = s.K0(:, inxObs, time);
    HOmg = s.H(inxObs, inxEM) * Omg(inxEM, :);
    if isRZero
        E2 = E2 + HOmg' * Fipe;
    else
        E2 = E2 + HOmg' * (Fipe - K0'*r);
    end
end

% Update `r`.
if isRZero
    r = s.Zt(:, inxObs)*Fipe;
else
    r = s.Zt(:, inxObs)*Fipe + s.L(:, :, time).'*r;
end

% Transition variables.
A2 = A0 + s.Pa0(:, :, time)*r;
if nf>0
    F2 = F0 + s.Pfa0(:, :, time)*r;
end
B2 = s.U*A2;

% Transition shocks.
RaOmg = Ra(:, inxET)*Omg(inxET, :);
E2 = E2 + RaOmg.'*r;

% Back out NaN measurement variables.
if any(~inxObs)
    Y2(~inxObs, :) = s.Z(~inxObs, :)*A2 + s.H(~inxObs, :)*E2;
    if numPOut>0
        % Correct the estimates of NaN observations for the effect of estimated
        % out-of-lik parameters.
        Y2(~inxObs, :) = Y2(~inxObs, :) + YDelta(~inxObs, :);
    end
    if ~isempty(D)
        % Correct the estimates of NaN observations for deterministic trends.
        Y2(~inxObs, 1) = Y2(~inxObs, 1) + D(~inxObs, :);
    end
end
    
end%

