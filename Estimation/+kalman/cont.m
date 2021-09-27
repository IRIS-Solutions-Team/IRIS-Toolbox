function s = cont(s)
% cont  Contributions of measurement variables to estimates of transition variables
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numY = size(s.Z, 1);
numB = size(s.Ta, 1);
numF = size(s.Tf, 1);
numE = size(s.Ra, 2);
numExtPeriods = size(s.y1, 2);

numContribs = numY;
numToEstim = s.NumOutlik + s.NumEstimInit;
needsEstimate = numToEstim>0;

Ta = s.Ta;
Tf = s.Tf;
U = s.U;
Z = s.Z;
yInx = s.yindex;
lastObs = s.LastObs;
lastSmooth = s.LastSmooth;
pe = s.peUnc;
yc1 = zeros(numY, numContribs, numExtPeriods);

%
% Prediction step
%
ac0 = nan(numB, numContribs, numExtPeriods);
yc0 = nan(numY, numContribs, numExtPeriods);
fc0 = nan(numF, numContribs, numExtPeriods);
bc0 = nan(numB, numContribs, numExtPeriods);
pec = nan(numY, numContribs, numExtPeriods);
ydeltac = zeros(numY, numContribs, numExtPeriods);
ac0(:, :, 1) = 0;
fc0(:, :, 1) = 0;
bc0(:, :, 1) = 0;
pec(:, :, 1) = 0;
if needsEstimate
    sumMtFiPec = zeros(numToEstim, numY);
end

for t = 2 : numExtPeriods
    % Effect of prediction error t-1 on time t predictions.
    jy1 = yInx(:, t-1);
    if any(jy1)
        upd = s.K1(:, jy1, t-1)*pec(jy1, :, t-1);
    else
        upd = 0;
    end
    ac0(:, :, t) = Ta*(ac0(:, :, t-1) + upd);
    % Prepare `pec` for next period.
    jy = yInx(:, t);
    yc0(:, :, t) = Z*ac0(:, :, t);
    % Create an artificial observation on `y1(jy, t)` based on the transition
    % vector with the effect of deterministic trends and constants removed, and
    % on the actual prediction error.
    y1 = sum(yc0(jy, :, t), 2) + pe(jy, t);
    yc1(jy, jy, t) = diag(y1);
    % Contributions of measurement variables to the prediction error.
    pec(jy, :, t) = yc1(jy, :, t) - yc0(jy, :, t);
    if needsEstimate
        sumMtFiPec = sumMtFiPec + s.MtFi(:, jy, t)*pec(jy, :, t);
    end
end

if needsEstimate
    estc = pinv(s.sumMtFiM) * sumMtFiPec;
    [pec, ac0, yc0, ydeltac] = kalman.correct(s, pec, ac0, yc0, estc, [ ]);
end

for t = 2 : numExtPeriods
    bc0(:, :, t) = U*ac0(:, :, t);
    if numF>0
        jy1 = yInx(:, t-1);
        fc0(:, :, t) = Tf*(ac0(:, :, t-1) + s.K1(:, jy1, t-1)*pec(jy1, :, t-1));
    end
end

s.ac0 = ac0;
if s.retPredCont
    s.yc0 = yc0;
    s.fc0 = fc0;
    s.bc0 = bc0;
    s.ec0 = zeros(numE, numContribs, numExtPeriods);
end

%
% Updating step
%
if s.retFilterCont
    fc1 = nan(numF, numY, numExtPeriods);
    bc1 = nan(numB, numY, numExtPeriods);
    ec1 = zeros(numE, numY, numExtPeriods);
    if lastObs<numExtPeriods
        yc1(:, :, lastObs+1:end) = yc0(:, :, lastObs+1:end);
        fc1(:, :, lastObs+1:end) = fc0(:, :, lastObs+1:end);
        bc1(:, :, lastObs+1:end) = bc0(:, :, lastObs+1:end);
    end
    for t = lastObs : -1 : 2
        jy = yInx(:, t);
        [yc1temp, fc1(:, :, t), bc1(:, :, t), ec1(:, :, t)] ...
            = kalman.oneStepBackMean(s, t, ...
            pec(:, :, t), ac0(:, :, t), fc0(:, :, t), ydeltac(:, :, t), [ ], 0);
        if any(~jy)
            yc1(~jy, :, t) = yc1temp(~jy, :);
        end
    end
    s.yc1 = yc1;
    s.fc1 = fc1;
    s.bc1 = bc1;
    s.ec1 = ec1;
end

%
% Smoothing step
%
if s.retSmoothCont
    yc2 = yc1;
    fc2 = nan(numF, numContribs, numExtPeriods);
    bc2 = nan(numB, numContribs, numExtPeriods);
    ec2 = zeros(numE, numContribs, numExtPeriods);
    if lastObs<numExtPeriods
        yc2(:, :, lastObs+1:end) = yc0(:, :, lastObs+1:end);
        fc2(:, :, lastObs+1:end) = fc0(:, :, lastObs+1:end);
        bc2(:, :, lastObs+1:end) = bc0(:, :, lastObs+1:end);
    end
    r = 0;
    for t = lastObs : -1 : lastSmooth
        jy = yInx(:, t);
        [yc2temp, fc2(:, :, t), bc2(:, :, t), ec2(:, :, t), r] ...
            = kalman.oneStepBackMean( ...
                s, t ...
                , pec(:, :, t), ac0(:, :, t), fc0(:, :, t) ...
                , ydeltac(:, :, t), [ ], r ...
            );
        if any(~jy)
            yc2(~jy, :, t) = yc2temp(~jy, :);
        end
    end
    s.yc2 = yc2;
    s.fc2 = fc2;
    s.bc2 = bc2;
    s.ec2 = ec2;
end

end%

