% solveFirstOrder  First-order quasi-triangular solution
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, info] = solveFirstOrder(this, variantsRequested, opt)

%
% exitFlag
%
%  Value      |  Meaning
% ------------|----------------------------------------
%      1      |  Unique stable solution
%      0      |  No stable solution (all explosive)
%     Inf     |  Multiple stable solutions
%     -1      |  NaN in solved matrices
%     -2      |  NaN in eigenvalues
%     -3      |  NaN derivatives in system matrices
%     -4      |  Steady state does not hold
%     -5      |  Unknown status
%

SOLVE_TOLERANCE = this.Tolerance.Solve;
EIGEN_TOLERANCE = this.Tolerance.Eigen;
SEVN2_TOLERANCE = this.Tolerance.Sevn2Patch;

%--------------------------------------------------------------------------

nv = countVariants(this);
inxY = this.Quantity.Type==1;
inxT = this.Equation.Type==1;
inxHash = this.Equation.InxHashEquations;
numHash = nnz(inxHash);
numObserved = nnz(this.Quantity.InxObserved);
numZ = numObserved;
numT = nnz(inxT);

info = struct();
info.ExitFlag = repmat(solve.StabilityFlag.UNKNOWN, 1, nv);
info.Singularity = false(numT, nv);
info.InxNanDeriv = cell(1, nv);
info.EigenValues = cell(1, nv);
info.SaddlePath = nan(3, nv);
info.SchurDecomposition = strings(1, nv);

if isequal(opt.Run, false)
    return
end

% Equation switch
doTransition = true; % Do transition equations
doMeasurement = true; % Do measurement equations
if startsWith(opt.Equations, "transition", "ignoreCase", true)
    doTransition = true;
    doMeasurement = false;
elseif startsWith(opt.Equations, "measurement", "ignoreCase", true)
    doTransition = false;
    doMeasurement = true;
end

[numY, ~, numXib, numXif, numE] = sizeSolution(this.Vector);
numXiWithinSystem = numel(this.Vector.System{2});
numXifWithinSystem = numXiWithinSystem - numXib; % Fwl variables in the system matrices

inxXfToKeep = ~this.D2S.IndexOfXfToRemove;
if isequal(variantsRequested, Inf)
    variantsRequested = 1 : nv;
end
variantsRequested = reshape(variantsRequested, 1, []);

% Solution matrices will be expanded to the match the existing expansion.
ahead = size(this.Variant.FirstOrderSolution{2}, 2)/numE - 1;

% Reset solution-dependent information in this.Variant.
if doTransition
    this.Variant = resetTransition( ...
        this.Variant, variantsRequested, this.Vector, numHash, numObserved ...
    );
end
if doMeasurement
    this.Variant = resetMeasurement(this.Variant, variantsRequested);
end

progress = [ ];
if isfield(opt, 'Progress') && isequal(opt.Progress, true)
    progress = ProgressBar('[IrisToolbox] @Model/solve Progress');
end

for v = variantsRequested
    % Differentiate equations and set up unsolved system matrices; check
    % for NaN derivatives.
    [system, info.InxNanDeriv{v}] = systemFirstOrder(this, v, opt);

    if any(info.InxNanDeriv{v})
        info.ExitFlag(v) = solve.StabilityFlag.NAN_SYSTEM;
        continue
    end

    % Check system matrices for complex numbers.
    if ~isreal(system.K{1}) ...
            || ~isreal(system.K{2}) ...
            || ~isreal(system.A{1}) ...
            || ~isreal(system.A{2}) ...
            || ~isreal(system.B{1}) ...
            || ~isreal(system.B{2}) ...
            || ~isreal(system.E{1}) ...
            || ~isreal(system.E{2})
        info.ExitFlag(v) = solve.StabilityFlag.COMPLEX_SYSTEM;
        continue
    end

    % Check system matrices for NaNs.
    if any(isnan(system.K{1})) ...
            || any(isnan(system.K{2})) ...
            || any(isnan(system.A{1}(:))) ...
            || any(isnan(system.A{2}(:))) ...
            || any(isnan(system.B{1}(:))) ...
            || any(isnan(system.B{2}(:))) ...
            || any(isnan(system.E{1}(:))) ...
            || any(isnan(system.E{2}(:)))
        info.ExitFlag(v) = solve.StabilityFlag.NAN_SYSTEM;
        continue
    end


    %
    % Schur decomposition & saddle-path check
    %
    if doTransition
        restoreWarnings = warning("query");
        if ~opt.Warning
            warning("off", join([exception.Base.IRIS_IDENTIFIER, "Model", "QZWarning"], ":"));
        end

        if opt.PreferredSchur=="qz" || numXifWithinSystem>0
            % Generalized Schur for models with fwl variables
            [SS, TT, QQ, ZZ, T0, equationOrder, eigen] = local_computeGeneralizedSchur(system, EIGEN_TOLERANCE, SEVN2_TOLERANCE);
            info.SchurDecomposition(v) = "qz";
        else
            % Plain Schur (after inversion) for models with bwl variables only
            [SS, TT, QQ, ZZ, T0, equationOrder, eigen] = local_computePlainSchur(system, EIGEN_TOLERANCE);
            info.SchurDecomposition(v) = "schur";
        end

        this.Variant.EigenValues(1, :, v) = eigen;
        info.EigenValues{v} = eigen;

        [this.Variant.EigenStability(1, :, v), info.SaddlePath(:, v), info.ExitFlag(v)] ...
            = local_verifyStability(eigen, numXib, EIGEN_TOLERANCE);

        warning(restoreWarnings);
    end


    if hasSucceeded(info.ExitFlag(v))
        if ~this.LinearStatus
            % Steady-state levels needed in here_transitionEquations() and
            % here_measurementEquations()
            isDelog = false;
            ssY = createTrendArray(this, v, isDelog, find(inxY), 0);
            ssXf = createTrendArray(this, v, isDelog, ...
                this.Vector.Solution{2}(1:numXif), [-1, 0]);
            ssXb = createTrendArray(this, v, isDelog, ...
                this.Vector.Solution{2}(numXif+1:end), [-1, 0]);
        end

        %
        % Solution matrices
        %
        flagTransition = true;
        flagMeasurement = true;
        if doMeasurement
            % Measurement matrices
            flagMeasurement = here_measurementEquations();
        end
        if doTransition
            % Transition matrices
            flagTransition = here_transitionEquations();
        end
        if ~flagTransition || ~flagMeasurement
            checkSteadyOptions = prepareCheckSteady(this, "EquationSwitch", "dynamic");
            if ~this.LinearStatus && ~implementCheckSteady(this, v, checkSteadyOptions);
                info.ExitFlag(v) = solve.StabilityFlag.INVALID_STEADY;
                continue;
            else
                info.ExitFlag(v) = solve.StabilityFlag.NAN_SOLUTION;
                continue;
            end
        end
        if numY>0
            % Transformed measurement matrices.
            transformMeasurement( );
        end
        if doTransition && ahead>0
            % Expand solution matrices up to t+ahead
            vthR = this.Variant.FirstOrderSolution{2}(:, 1:numE, v);
            vthY = this.Variant.FirstOrderSolution{8}(:, 1:numHash, v);
            vthExpansion = getIthFirstOrderExpansion(this.Variant, v);
            [vthR, vthY] = model.expandFirstOrder(vthR, vthY, vthExpansion, ahead);
            this.Variant.FirstOrderSolution{2}(:, :, v) = vthR;
            this.Variant.FirstOrderSolution{8}(:, :, v) = vthY;
        end
    end

    if ~isempty(progress)
        update(progress, v/length(variantsRequested));
    end
end

info.ExitFlag = info.ExitFlag(variantsRequested);
info.InxNanDeriv = info.InxNanDeriv(variantsRequested);
info.SchurDecomposition = info.SchurDecomposition(variantsRequested);
info.Singularity = info.Singularity(:, variantsRequested);
info.SaddlePath = info.SaddlePath(:, variantsRequested);
info.EigenValues = info.EigenValues(variantsRequested);

return

    function flag = here_transitionEquations()
        flag = true;
        isHash = any(inxHash);

        if ~isempty(SS)
            S11 = SS(1:numXib, 1:numXib);
            S12 = SS(1:numXib, numXib+1:end);
            S22 = SS(numXib+1:end, numXib+1:end);
        else
            S11 = 1;
            S12 = zeros(numXib, 0);
            S22 = zeros(0, 0);
        end

        T11 = TT(1:numXib, 1:numXib);
        T12 = TT(1:numXib, numXib+1:end);
        T22 = TT(numXib+1:end, numXib+1:end);

        Z11 = ZZ(inxXfToKeep, 1:numXib);
        Z12 = ZZ(inxXfToKeep, numXib+1:end);
        Z21 = ZZ(numXifWithinSystem+1:end, 1:numXib);
        Z22 = ZZ(numXifWithinSystem+1:end, numXib+1:end);

        % Transform the other system matrices by QQ
        if equationOrder(1)==1
            % No equation re-ordering.
            % Constant.
            C = QQ*system.K{2};
            % Effect of transition shocks.
            D = QQ*full(system.E{2});
            if isHash
                % Effect of add-factors in transition equations earmarked
                % for nonlinear simulations.
                N = QQ*system.N{2};
            end
        else
            % Equations have been re-ordered while computing QZ.
            % Constant.
            C = QQ*system.K{2}(equationOrder, :);
            % Effect of transition shocks.
            D = QQ*full(system.E{2}(equationOrder, :));
            if isHash
                % Effect of add-factors in transition equations earmarked
                % for nonlinear simulations.
                N = QQ*system.N{2}(equationOrder, :);
            end
        end

        C1 = C(1:numXib, 1);
        C2 = C(numXib+1:end, 1);
        D1 = D(1:numXib, :);
        D2 = D(numXib+1:end, :);
        if isHash
            N1 = N(1:numXib, :);
            N2 = N(numXib+1:end, :);
        end

        % Rotation matrix for the Quasi-triangular state-space form

        U = Z21;


        % Singularity in the rotation matrix; something's wrong with the model
        % because this is supposed to be regular by construction.

        if rcond(U)<=SOLVE_TOLERANCE
            flag = false;
            return
        end


        % Steady state for nonlinear models. They are needed in nonlinear
        % models to back out the constant vectors.

        if ~this.LinearStatus
            ssA = U \ ssXb;
            if any(isnan(ssA(:)))
                flag = false;
                return
            end
        end


        % __Unstable block__


        G = -Z21\Z22;
        if any(isnan(G(:)))
            flag = false;
            return
        end


        Ru = -T22\D2;
        if any(isnan(Ru(:)))
            flag = false;
            return
        end

        if isHash
            Yu = -T22\N2;
            if any(isnan(Yu(:)))
                flag = false;
                return
            end
        end

        if this.LinearStatus
            Ku = -(S22+T22)\C2;
        else
            Ku = zeros(numXif, 1);
        end
        if any(isnan(Ku(:)))
            flag = false;
            return
        end

        % Transform stable block==transform backward-looking variables:
        % a(t) = s(t) + G u(t+1).

        Ta = -S11\T11;
        if any(isnan(Ta(:)))
            flag = false;
            return
        end
        Xa0 = S11\(T11*G + T12);
        if any(isnan(Xa0(:)))
            flag = false;
            return
        end

        Ra = -Xa0*Ru - S11\D1;
        if any(isnan(Ra(:)))
            flag = false;
            return
        end

        if isHash
            Ya = -Xa0*Yu - S11\N1;
            if any(isnan(Ya(:)))
                flag = false;
                return
            end
        end

        Xa1 = G + S11\S12;
        if any(isnan(Xa1(:)))
            flag = false;
            return
        end
        if this.LinearStatus
            Ka = -(Xa0 + Xa1)*Ku - S11\C1;
        else
            Ka = ssA(:, 2) - Ta*ssA(:, 1);
        end
        if any(isnan(Ka(:)))
            flag = false;
            return
        end


        % __Forward-looking variables__


        % Duplicit rows have been already deleted from Z11 and Z12.
        Tf = Z11;
        Xf = Z11*G + Z12;
        Rf = Xf*Ru;
        if isHash
            Yf = Xf*Yu;
        end
        if this.LinearStatus
            Kf = Xf*Ku;
        else
            Kf = ssXf(:, 2) - Tf*ssA(:, 1);
        end
        if any(isnan(Kf(:)))
            flag = false;
            return
        end

        % State-space form:
        % [xif(t);a(t)] = T a(t-1) + K + R(L) e(t) + Y(L) addfactor(t),
        % U a(t) = xib(t).
        T = [Tf;Ta];
        R = [Rf;Ra];
        K = [Kf;Ka];
        if isHash
            Y = [Yf;Ya];
        end

        this.Variant.FirstOrderSolution{1}(:, :, v) = T;
        this.Variant.FirstOrderSolution{2}(:, 1:numE, v) = R;
        this.Variant.FirstOrderSolution{3}(:, :, v) = K;
        this.Variant.FirstOrderSolution{7}(:, :, v) = U;
        if isHash
            this.Variant.FirstOrderSolution{8}(:, 1:numHash, v) = Y;
        end

        if isempty(T0)
            % Calculate rectangular transition matrix if not supplied from plain Schur
            T0 = [Tf/U; U*Ta/U];
        end
        this.Variant.FirstOrderSolution{10}(:, :, v) = T0;

        % Necessary initial conditions in xib vector
        this.Variant.IxInit(:, :, v) = any(abs(T0)>SOLVE_TOLERANCE, 1);

        % Forward expansion
        % a(t) <<< -Xa J^(k-1) Ru e(t+k)
        % xif(t) <<< Xf J^k Ru e(t+k)
        J = -T22\S22;
        Xa = Xa1 + Xa0*J;
        % Highest computed power of J: e(t+k) requires J^k.
        % Jk = eye(size(J));

        this.Variant.FirstOrderExpansion{1}(:, :, v) = Xa;
        this.Variant.FirstOrderExpansion{2}(:, :, v) = Xf;
        this.Variant.FirstOrderExpansion{3}(:, :, v) = Ru;
        this.Variant.FirstOrderExpansion{4}(:, :, v) = J;
        if isHash
            this.Variant.FirstOrderExpansion{5}(:, :, v) = Yu;
        end
    end%


    function flag = here_measurementEquations( )
        flag = true;
        % First, create untransformed measurement equation; the transformed
        % measurement matrix will be calculated later on.
        % y(t) = ZZ xib(t) + D + H e(t)
        Zb = zeros(0, numXib);
        H = zeros(0, numE);
        D = zeros(0, 1);
        if numZ>0
            % Transition variables marked for measurement
            pos = find(this.Quantity.IxObserved);
            xibVector = this.Vector.Solution{2}(numXif+1:end);
            Zb = zeros(numZ, numXib);
            inx = bsxfun(@eq, pos(:), xibVector);
            Zb(inx) = 1;
        elseif numY>0
            % Measurement variables
            Zb = -full(system.A{1}\system.B{1});
            if any(isnan(Zb(:)))
                flag = false;
                % Find singularities in measurement equations and their culprits
                if rcond(full(system.A{1}))<=SOLVE_TOLERANCE
                    s = size(system.A{1}, 1);
                    r = rank(full(system.A{1}));
                    d = s - r;
                    [u, ~] = svd(full(system.A{1}));
                    info.Singularity(:, v) = any( abs(u(:, end-d+1:end))>SOLVE_TOLERANCE, 2 );
                end
                return
            end
            H = -full(system.A{1}\system.E{1});
            if any(isnan(H(:)))
                flag = false;
                return
            end
            if this.LinearStatus
                D = full(-system.A{1}\system.K{1});
            else
                D = ssY - Zb*ssXb(:, 2);
            end
            if any(isnan(D(:)))
                flag = false;
                return
            end
        end
        % this.Variant.FirstOrderSolution{4}(:, :, v) is assigned la.
        this.Variant.FirstOrderSolution{5}(:, :, v) = H;
        this.Variant.FirstOrderSolution{6}(:, :, v) = D;
        this.Variant.FirstOrderSolution{9}(:, :, v) = Zb;
    end%


    function transformMeasurement( )
        % Transform the Zb matrix to Za:
        %     y = Zb*xib -> y = Za*alpha
        Zb = this.Variant.FirstOrderSolution{9}(:, :, v);
        U = this.Variant.FirstOrderSolution{7}(:, :, v);
        Za = Zb*U;
        this.Variant.FirstOrderSolution{4}(:, :, v) = Za;
    end%
end

%
% Local functions
%

function [eigenStability, bk, exitFlag] = local_verifyStability(eigenValues, numXib, tolerance)
    %(
    absEigen = abs(eigenValues);
    inxStableRoots = absEigen<=(1-tolerance);
    inxUnitRoots = abs(absEigen-1)<tolerance;
    numUnitRoots = nnz(inxUnitRoots);
    numStableRoots = nnz(inxStableRoots);


    % Check BK saddle-path condition

    if any(isnan(eigenValues))
        exitFlag = solve.StabilityFlag.NAN_EIGEN;
    elseif numXib==numStableRoots+numUnitRoots
        exitFlag = solve.StabilityFlag.UNIQUE_STABLE;
    elseif numXib>numStableRoots+numUnitRoots
        exitFlag = solve.StabilityFlag.NO_STABLE;
    else
        exitFlag = solve.StabilityFlag.MULTIPLE_STABLE;
    end

    eigenStability = repmat(0, 1, numel(eigenValues));
    eigenStability(1, inxStableRoots) = 0;
    eigenStability(1, inxUnitRoots) = 1;
    eigenStability(1, ~inxStableRoots & ~inxUnitRoots) = 2;

    numStableRoots = nnz(eigenStability(1, :)==0);
    numUnitRoots = nnz(eigenStability(1, :)==1);
    bk = [numXib; numUnitRoots; numStableRoots];
    %)
end%


function [SS, TT, QQ, ZZ, T0, equationOrder, eigen] = local_computeGeneralizedSchur(system, tolerance, sevn2Tolerance)
    %(
    T0 = [];

    fullA = full(system.A{2});
    fullB = full(system.B{2});
    equationOrder = 1 : size(fullA, 1);


    % If the QZ re-ordering fails, change the order of equations --
    % move the first equation last, and repeat

    while true
        AA = fullA(equationOrder, :);
        BB = fullB(equationOrder, :);
        [SS, TT, QQ, ZZ] = qz(AA, BB, "real");
        % Ordered inverse eigvals.
        invEigen = -ordeig(SS, TT);
        invEigen = reshape(invEigen, 1, []);
        isSevn2 = here_applySevn2Patch();
        absInvEigen = abs(invEigen);
        inxStableRoots = absInvEigen>=(1+tolerance);
        inxUnitRoots = abs(absInvEigen-1)<tolerance;
        % Clusters of unit, stable, and unstable eigenvalues.
        clusters = zeros(size(invEigen));
        % Unit roots first.
        clusters(inxUnitRoots) = 2;
        % Stable roots second.
        clusters(inxStableRoots) = 1;
        % Unstable roots last.
        % Re-order by the clusters.
        lastwarn("");
        [SS, TT, QQ, ZZ] = ordqz(SS, TT, QQ, ZZ, clusters);
        isEmptyWarning = isempty(lastwarn());

        % If the first equations is ordered second, it indicates the
        % next cycle would bring the equations to their original order.
        % We stop and throw an error.

        if isEmptyWarning || equationOrder(2)==1
            break
        else
            equationOrder = equationOrder([2:end, 1]);
        end
    end

    if ~isEmptyWarning
        exception.error([
            "Model:QZError"
            "QZ reordering failed because some eigenvalues are too close to swap "
            "and equation reordering does not help."
        ]);
    end

    if equationOrder(1)~=1
        exception.warning([
            "Model:QZWarning"
            "Numerical instability detected in QZ decomposition. "
            "Model equations were reordered a total of %g times "
            "before finding a stable decomposition."
        ], equationOrder(1)-1);
    end


    % Reorder inverse eigenvalues

    invEigen = -ordeig(SS, TT);
    invEigen = reshape(invEigen, 1, []);
    isSevn2 = here_applySevn2Patch() | isSevn2;
    if isSevn2
        exception.warning([
            "Model"
            "Numerical instability detected in QZ decomposition; "
            "the SEVN2 patch was applied to the system matrix factors. "
        ]);
    end


    % Undo eigen value inversion
    eigen = invEigen;
    inxInfEigen = invEigen==0;
    eigen(~inxInfEigen) = 1 ./ invEigen(~inxInfEigen);
    eigen(inxInfEigen) = Inf;

    return

        function flag = here_applySevn2Patch( )
            % Sum of two eigvals near to 2 may indicate inaccuracy
            % Largest eigval less than 1
            flag = false;
            eigval0 = invEigen;
            eigval0(abs(invEigen)>=1-tolerance) = 0;
            eigval0(imag(invEigen)~=0) = 0;
            if any(eigval0<=0)
                [~, below] = max(abs(eigval0)); %#ok<*NOANS>
            else
                below = [ ];
            end
            % Smallest eig greater than 1
            eigval0 = invEigen;
            eigval0(abs(invEigen)<=1+tolerance) = Inf;
            eigval0(imag(invEigen)~=0) = Inf;
            if any(~isinf(eigval0))
                [~, above] = min(abs(eigval0));
            else
                above = [ ];
            end
            if ~isempty(below) && ~isempty(above) ...
                    && abs(invEigen(below) + invEigen(above) - 2)<=tolerance ...
                    && abs(invEigen(below) - 1)<=sevn2Tolerance
                invEigen(below) = sign(invEigen(below));
                invEigen(above) = sign(invEigen(above));
                TT(below, below) = sign(TT(below, below))*abs(SS(below, below));
                TT(above, above) = sign(TT(above, above))*abs(SS(above, above));
                flag = true;
            end
        end%
    %)
end%


function [SS, TT, QQ, ZZ, T0, eqOrder, eigen] = local_computePlainSchur(system, tolerance)
    %(
    eqOrder = 1 : size(system.A{2}, 1);

    T0 = system.A{2} \ system.B{2};
    [ZZ, TT] = schur(full(T0), "real");
    T0 = -T0;

    eigen = -ordeig(TT);
    inxUnitRoots = abs(abs(eigen)-1)<tolerance;
    % Clusters of unit, stable, and unstable eigenvalues.
    % Unit roots first
    clusters = zeros(size(eigen));
    clusters(inxUnitRoots) = 1;
    [ZZ, TT] = ordschur(ZZ, TT, clusters);
    eigen = -ordeig(TT);

    SS = []; % SS = eye(size(A));
    % QQ = transpose(ZZ) * invA;
    QQ = transpose(ZZ) / system.A{2};
    %)
end%

