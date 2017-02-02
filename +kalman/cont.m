function S = cont(S)
% cont  Contributions of measurement variables to estimates of transition variables.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z, 1);
nb = size(S.Ta, 1);
nf = size(S.Tf, 1);
ne = size(S.Ra, 2);
nPer = size(S.y1, 2);

nCont = ny;
nPOut = S.NPOut;
nInit = S.NInit; % Numbver of init conditions estimated as fixed unknowns.
nEst = nPOut + nInit;
isEst = nEst>0;
Ta = S.Ta;
Tf = S.Tf;
U = S.U;
Z = S.Z;
yInx = S.yindex;
lastObs = S.lastObs;
lastSmooth = S.lastSmooth;
pe = S.peUnc;
yc1 = zeros(ny, nCont, nPer);

% Prediction step
%-----------------
ac0 = nan(nb, nCont, nPer);
yc0 = nan(ny, nCont, nPer);
fc0 = nan(nf, nCont, nPer);
bc0 = nan(nb, nCont, nPer);
pec = nan(ny, nCont, nPer);
ydeltac = zeros(ny, nCont, nPer);
ac0(:, :, 1) = 0;
fc0(:, :, 1) = 0;
bc0(:, :, 1) = 0;
pec(:, :, 1) = 0;
if isEst
    sumMtFiPec = zeros(nEst, ny);
end

for t = 2 : nPer
    % Effect of prediction error t-1 on time t predictions.
    jy1 = yInx(:, t-1);
    if any(jy1)
        upd = S.K1(:, jy1, t-1)*pec(jy1, :, t-1);
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
    if isEst
        sumMtFiPec = sumMtFiPec + S.MtFi(:, jy, t)*pec(jy, :, t);
    end
end

if isEst
    estc = pinv(S.sumMtFiM) * sumMtFiPec;
    [pec, ac0, yc0, ydeltac] = kalman.correct(S, pec, ac0, yc0, estc, [ ]);
end

for t = 2 : nPer
    bc0(:, :, t) = U*ac0(:, :, t);
    if nf>0
        jy1 = yInx(:, t-1);
        fc0(:, :, t) = Tf*(ac0(:, :, t-1) + S.K1(:, jy1, t-1)*pec(jy1, :, t-1));
    end
end

S.ac0 = ac0;
if S.retPredCont
    S.yc0 = yc0;
    S.fc0 = fc0;
    S.bc0 = bc0;
    S.ec0 = zeros(ne, nCont, nPer);
end

% Updating step
%---------------
if S.retFilterCont
    fc1 = nan(nf, ny, nPer);
    bc1 = nan(nb, ny, nPer);
    ec1 = zeros(ne, ny, nPer);
    if lastObs<nPer
        yc1(:, :, lastObs+1:end) = yc0(:, :, lastObs+1:end);
        fc1(:, :, lastObs+1:end) = fc0(:, :, lastObs+1:end);
        bc1(:, :, lastObs+1:end) = bc0(:, :, lastObs+1:end);
    end
    for t = lastObs : -1 : 2
        jy = yInx(:, t);
        [yc1temp, fc1(:, :, t), bc1(:, :, t), ec1(:, :, t)] ...
            = kalman.oneStepBackMean(S, t, ...
            pec(:, :, t), ac0(:, :, t), fc0(:, :, t), ydeltac(:, :, t), [ ], 0);
        if any(~jy)
            yc1(~jy, :, t) = yc1temp(~jy, :);
        end
    end
    S.yc1 = yc1;
    S.fc1 = fc1;
    S.bc1 = bc1;
    S.ec1 = ec1;
end

% Smoothing step
%----------------
if S.retSmoothCont
    yc2 = yc1;
    fc2 = nan(nf, nCont, nPer);
    bc2 = nan(nb, nCont, nPer);
    ec2 = zeros(ne, nCont, nPer);
    if lastObs<nPer
        yc2(:, :, lastObs+1:end) = yc0(:, :, lastObs+1:end);
        fc2(:, :, lastObs+1:end) = fc0(:, :, lastObs+1:end);
        bc2(:, :, lastObs+1:end) = bc0(:, :, lastObs+1:end);
    end
    r = 0;
    for t = lastObs : -1 : lastSmooth
        jy = yInx(:, t);
        [yc2temp, fc2(:, :, t), bc2(:, :, t), ec2(:, :, t), r] ...
            = kalman.oneStepBackMean(S, t, ...
            pec(:, :, t), ac0(:, :, t), fc0(:, :, t), ydeltac(:, :, t), [ ], r);
        if any(~jy)
            yc2(~jy, :, t) = yc2temp(~jy, :);
        end
    end
    S.yc2 = yc2;
    S.fc2 = fc2;
    S.bc2 = bc2;
    S.ec2 = ec2;
end
end
