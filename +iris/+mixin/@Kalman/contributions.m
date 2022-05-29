% cont  Contributions of measurement variables to estimates of transition variables
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function s = contributions(s)

addDeterministic = @(xc, x) cat(2, xc, x-sum(xc, 2));

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
    [pec, ac0, yc0, ydeltac] = iris.mixin.Kalman.correct(s, pec, ac0, yc0, estc, []);
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
    s.yc0 = addDeterministic(yc0, s.y0);
    s.fc0 = addDeterministic(fc0, s.f0);
    s.bc0 = addDeterministic(bc0, s.b0);
    s.ec0 = zeros(numE, numContribs+1, numExtPeriods);
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
            = iris.mixin.Kalman.oneStepBackMean(s, t, ...
            pec(:, :, t), ac0(:, :, t), fc0(:, :, t), ydeltac(:, :, t), [ ], 0);
        if any(~jy)
            yc1(~jy, :, t) = yc1temp(~jy, :);
        end
    end
    s.yc1 = addDeterministic(yc1, permute(s.y1, [1, 3, 2]));
    s.fc1 = addDeterministic(fc1, permute(s.f1, [1, 3, 2]));
    s.bc1 = addDeterministic(bc1, permute(s.b1, [1, 3, 2]));
    s.ec1 = addDeterministic(ec1, permute(s.e1, [1, 3, 2]));
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
            = iris.mixin.Kalman.oneStepBackMean( ...
                s, t ...
                , pec(:, :, t), ac0(:, :, t), fc0(:, :, t) ...
                , ydeltac(:, :, t), [ ], r ...
            );
        if any(~jy)
            yc2(~jy, :, t) = yc2temp(~jy, :);
        end
    end
    s.yc2 = addDeterministic(yc2, permute(s.y2, [1, 3, 2]));
    s.fc2 = addDeterministic(fc2, permute(s.f2, [1, 3, 2]));
    s.bc2 = addDeterministic(bc2, permute(s.b2, [1, 3, 2]));
    s.ec2 = addDeterministic(ec2, permute(s.e2, [1, 3, 2]));
end

end%

