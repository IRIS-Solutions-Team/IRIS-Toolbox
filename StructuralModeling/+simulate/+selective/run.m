function [YRpt, XxRpt, EaRpt, EuRpt, WRpt, Exit, Dcy, Addf] = run(S)
% run  Equation-selective nonlinear simulation
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = size(S.Z, 1);
nxx = size(S.T, 1);
nb = size(S.T, 2);
nf = nxx - nb;
ne = size(S.Ea, 1);
nPer = size(S.Ea, 2);
ixNonl = S.Selective.IxHash;
nn = sum(ixNonl);
nPerNonl = S.NPerNonlin;
isAnch = ~isempty(S.Anch) && any(S.Anch(:));

% Split non-linear simulation into segments of unanticipated shocks, and
% simulate one segment at a time.
sgm = simulate.selective.findsegments(S);
nSgm = length(sgm);

% Store anticipated and unanticipated shocks outside S and remove them from
% S; they will be supplied in S for a segment specific range in each step.
ea = S.Ea;
eu = S.Eu;
S.Ea = [ ];
S.Eu = [ ];

nPerMax = max( nPer , sgm(end)+nPerNonl-1 );

% Store all anchors outside S and remove them from S; they will be supplied
% in S for a segment specific range in each step.
anch = S.Anch;
wght = S.Wght;
tune = S.Tune;
yxxAnch = anch(1:ny+nxx, :);
eaAnch = anch(ny+nxx+(1:ne), :);
euAnch = anch(ny+nxx+ne+(1:ne), :);
isEaAnch = any(eaAnch(:) ~= 0);
isEuAnch = any(euAnch(:) ~= 0);
if S.IsDeviation && S.IsAddSstate
    xBar = S.XBar;
    yBar = S.YBar;
end

lastEa = utils.findlast(ea);
lastExg = utils.findlast(yxxAnch);
lastEndgA = utils.findlast(eaAnch);

% Try to create updating matrices before S.Anch is emptied. Do not create
% updating matrices if the total number of data points to update exceeds
% MAX_N_UPD.
S.Selective.Jv = [ ];
S.Selective.IxUpd =  [ ];
isFastUpd = false;
fastUpdate( );

S.Anch = [ ];
S.Wght = [ ];
S.Tune = [ ];
if S.IsDeviation && S.IsAddSstate
    S.XBar = [ ];
    S.YBar = [ ];
end

% If the last simulated period in the last segment goes beyond `nPer`, we
% expand the below arrays accordingly, so that it is easier to set up their
% segment-specific version in S.
if nPer < nPerMax
    ea(:, end+1:nPerMax) = 0;
    eu(:, end+1:nPerMax) = 0;
    if isEaAnch || isEuAnch
        anch(:, end+1:nPerMax) = false;
        wght(:, end+1:nPerMax) = 0;
        tune(:, end+1:nPerMax) = NaN;
    end
end

% Arrays reported in nonlinear simulations.
YRpt = zeros(ny, 0);
WRpt = zeros(nxx, 0);
XxRpt = zeros(nxx, 0);
EaRpt = zeros(ne, 0);
EuRpt = zeros(ne, 0);

% Correction vector for nonlinear equations.
v = zeros(nn, 0);

Exit = zeros(1, nSgm);
Addf = nan(nn, nPerMax, nSgm);
Dcy = nan(nn, nPer);

for iSgm = 1 : nSgm
    % The segment dates are defined by `first` to `last`, a total of `nper1`
    % periods. These are the dates that will be added to the output data.
    % However, the actual range to be simulated can be longer because
    % `lastNonlin` (the number of non-linearised periods) may go beyond `last`.
    first = sgm(iSgm);
    S.First = first;
    if iSgm < nSgm
        lastRpt = sgm(iSgm+1) - 1;
    else
        lastRpt = nPer;
    end
    % Last period simulated in nonlinear mode.
    lastNonl = first + nPerNonl - 1;
    % Last period simulated.
    lastSim = max([lastRpt, lastNonl, lastEa, lastEndgA, lastExg]);
    % Number of periods reported in the final output data.
    nPerRpt = lastRpt - first + 1;
    % Number of periods simulated.
    nPerSim = lastSim - first + 1;
    nPerUsed = min(nPerRpt, nPerNonl);
    
    % Prepare shocks: Combine anticipated shocks on the whole segment with
    % unanticipated shocks in the initial period.
    rangeSim = first : lastSim;
    S.Ea = ea(:, rangeSim);
    S.Eu = eu(:, first);
    
    % Steady-state trends; they include pre-sample init condition.
    if S.IsDeviation && S.IsAddSstate
        S.XBar = xBar(:, 1+(first-1:lastSim));
        S.YBar = yBar(:, 1+(first-1:lastSim));
    end
    
    % Prepare anchors: Anticipated and unanticipated endogenised shocks cannot
    % be combined in non-linear simulations. If there is no anchors, we can
    % leave the fields empty.
    if isEaAnch
        S.Anch = anch(:, rangeSim);
        S.Wght = wght(:, rangeSim);
        S.Tune = tune(:, rangeSim);
    elseif isEuAnch
        S.Anch = [anch(:, first), false(ny+nxx+ne+ne, nPerSim-1)];
        S.Wght = [wght(:, first), zeros(ne+ne, nPerSim-1)];
        S.Tune = [tune(:, first), nan(ny+nxx, nPerSim-1)];
    end
    S.Anch(ny+nxx+ne+(1:ne), 2:end) = false; % Reset unanticipated anchors.
    S.Wght(ne+(1:ne), 2:end) = 0; % Reset unanticipated weights.

    % Reset counters and flags.
    S.Stop = 0;
    
    % Re-use addfactors from the previous segment.
    v(:, end+1:nPerNonl) = 0;

    % Create segment string.
    s = sprintf( '%g:%g[%g]#%g', ...
                 S.ZerothSegment+first, ...
                 S.ZerothSegment+lastRpt, ...
                 S.ZerothSegment+lastSim, ...
                 nPerNonl );
    S.Selective.SegmentString = sprintf('%16s', s);
    
    % Simulate this segment
    %-----------------------
    S.Selective.NPerNonlin = nPerNonl;
    S.Selective.NPerSim = nPerSim;
    S.Selective.Je = [ ];
    if isAnch
        % We need multipliers `M` for both fast and regular exog/endog update.
        S.M = simulate.linear.multipliers(S);
        if isFastUpd
            % Get a multliplier matrix only for the elements of yxx that enter
            % nonlinear equations.
            yxAnch = repmat(S.Selective.IxUpdN, 1, nPerNonl);
            S.Selective.Je = simulate.linear.multipliers(S, yxAnch);
        end
    end
    
    % Iterate over nonlinear factors.
    [v, iDcy, iExit] = simulate.selective.segment(S, v);
    
    % Rerun simulation with nonlinear factors for `nPerSim` periods.
    [iY, iXx, iEa, iEu, iW] = simulate.linear.run(S, nPerSim, v);
    
    YRpt = [YRpt, iY(:, 1:nPerRpt)]; %#ok<AGROW>
    WRpt = [WRpt, iW(:, 1:nPerRpt)]; %#ok<AGROW>
    XxRpt = [XxRpt, iXx(:, 1:nPerRpt)]; %#ok<AGROW>
    EaRpt = [EaRpt, iEa(:, 1:nPerRpt)]; %#ok<AGROW>
    EuRpt = [EuRpt, iEu(:, 1), zeros(ne, nPerRpt-1)]; %#ok<AGROW>
    
    % Update initial condition for next segment.
    S.Alp0 = iW(nf+1:end, nPerRpt);
    
    % Report diagnostic output arguments.
    Dcy(:, first+(0:nPerUsed-1)) = iDcy(:, 1:nPerUsed);
    Addf(:, first+(0:size(v, 2)-1), iSgm) = v;
    Exit(iSgm) = iExit;
    
    % Remove add-factors within the current segment's reported range. Any
    % add-factors going beyond the reported range end will be used as starting
    % values in the next segment.
    v(:, 1:nPerUsed) = [ ];
    
    % Update progress bar only if no iteration reports are printed.
    if ~isempty(S.progress)
        update(S.progress, ((S.ILoop-1)*nSgm+iSgm)/(S.NLoop*nSgm));
    end
end

return

    
    function fastUpdate( )
        % Index of elements in [y;xx] vector that need to be updated in nonlinear
        % simulations:
        % * variables that occur in nonlinear equations
        % * exogenized variables.
        nPerJ =  max(nPerNonl, lastExg);
        ixUpd = S.Selective.IxUpdN;
        if isAnch
            ixUpd = ixUpd | any(S.Anch(1:ny+nxx, :), 2);
        end
        nIxUpd = nnz(ixUpd);
        
        numelJv = (nIxUpd*nPerJ)*(nn*nPerNonl);
        isFastUpd = numelJv<=S.Selective.MaxNumelJv;
        
        % If there are too many data points to update, leave Jv empty, and switch
        % to `simulate.linear.run`.
        if ~isFastUpd
            return
        end
        
        Jvt = zeros(ny+nxx, nn*nPerNonl);
        Jv = zeros(nIxUpd*nPerJ, nn*nPerNonl); % Effect of nonlinear addfactors.
        for tt = 1 : nPerJ
            if tt==1
                Q = S.Q(:, 1:nn*nPerNonl);
                Jwv = Q;
            elseif tt<=nPerNonl
                Q(:) = [ zeros(nxx, nn), Q(:, 1:end-nn) ];
                Jwv(:) = S.T*Jwv(nf+1:end, :) + Q;
            else
                Jwv(:) = S.T*Jwv(nf+1:end, :);
            end
            Jvt(:) = [ ...
                S.Z*Jwv(nf+1:end, :); ...
                Jwv(1:nf, :); ...
                S.U*Jwv(nf+1:end, :); ...
                ];
            Jv((tt-1)*nIxUpd+(1:nIxUpd), :) = Jvt(ixUpd, :);
        end
        S.Selective.Jv = Jv;
        S.Selective.IxUpd = ixUpd;
    end%
end%
