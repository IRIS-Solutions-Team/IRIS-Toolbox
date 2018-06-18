function [this, exitFlag, nanDeriv, sing1, bk] = solveFirstOrder(this, variantsRequired, opt)
% solveFirstOrder  First-order quasi-triangular solution
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

% exitFlag
% * 1 .. Unique stable solution
% * 0 .. No stable solution (all explosive)
% * Inf .. Multiple stable solutions
% * -1 .. NaN in solved matrices
% * -2 .. NaN in eigenvalues
% * -3 .. NaN derivatives in system matrices
% * -4 .. Steady state does not hold

TYPE = @int8;
SOLVE_TOLERANCE = this.Tolerance.Solve;
EIGEN_TOLERANCE = this.Tolerance.Eigen;
SEVN2_TOLERANCE = this.Tolerance.Sevn2Patch;

%--------------------------------------------------------------------------

doTransition = true; % Do transition equations.
doMeasurement = true; % Do measurement equations.
if strcmpi(opt.Eqtn, 'transition')
    doTransition = true;
    doMeasurement = false;
elseif strcmpi(opt.Eqtn, 'measurement')
    doTransition = false;
    doMeasurement = true;
end

ixy = this.Quantity.Type==TYPE(1);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixt = this.Equation.Type==1;
ixh = this.Equation.IxHash;
numHashed = nnz(ixh);
numObserved = nnz(this.Quantity.IxObserved);
nh = numHashed;
nz = numObserved;
nt = nnz(ixt);

[ny, nxi, nb, nf, ne] = sizeOfSolution(this.Vector);
kxi = length(this.Vector.System{2});
kf = kxi - nb; % Fwl in system.
indexXfToKeep = ~this.D2S.IndexOfXfToRemove;
nv = length(this);
if isequal(variantsRequired, Inf)
    variantsRequired = 1 : nv;
end
variantsRequired = variantsRequired(:).';
numVariantsRequired = length(variantsRequired);

% Solution matrices will be expanded to the match the existing expansion.
ahead = size(this.Variant.FirstOrderSolution{2}, 2)/ne - 1;

% Reset solution-dependent information in this.Variant.
if doTransition
    this.Variant = resetTransition( ...
        this.Variant, variantsRequired, this.Vector, numHashed, numObserved ...
    );
end
if doMeasurement
    this.Variant = resetMeasurement(this.Variant, variantsRequired);
end

% Set `NPATH` to 1 initially to handle correctly the cases when only a
% subset of parameterisations is solved for.
exitFlag = ones(1, nv);
sing1 = false(nt, nv);
nanDeriv = cell(1, nv);
bk = nan(3, nv);

if opt.Progress
    progress = ProgressBar('IRIS model.solve progress');
end

for v = variantsRequired
    % Differentiate equations and set up unsolved system matrices; check
    % for NaN derivatives.
    [syst, nanDeriv{v}] = systemFirstOrder(this, v, opt);
    if any(nanDeriv{v})
        exitFlag(v) = -3;
        continue
    end
    
    % Check system matrices for complex numbers.
    if ~isreal(syst.K{1}) ...
            || ~isreal(syst.K{2}) ...
            || ~isreal(syst.A{1}) ...
            || ~isreal(syst.A{2}) ...
            || ~isreal(syst.B{1}) ...
            || ~isreal(syst.B{2}) ...
            || ~isreal(syst.E{1}) ...
            || ~isreal(syst.E{2})
        exitFlag(v) = 1i;
        continue;
    end
    % Check system matrices for NaNs.
    if any(isnan(syst.K{1})) ...
            || any(isnan(syst.K{2})) ...
            || any(isnan(syst.A{1}(:))) ...
            || any(isnan(syst.A{2}(:))) ...
            || any(isnan(syst.B{1}(:))) ...
            || any(isnan(syst.B{2}(:))) ...
            || any(isnan(syst.E{1}(:))) ...
            || any(isnan(syst.E{2}(:)))
        exitFlag(v) = NaN;
        continue;
    end
    
    % __Schur Decomposition and Saddle-Path Check__
    if doTransition
        [SS, TT, QQ, ZZ, eqOrd, numUnitRoots, numStableRoots] = computeSchur( );
        bk(:, v) = [nb; numUnitRoots; numStableRoots] ;
    end
    
    if exitFlag(v)==1
        if ~this.IsLinear
            % Steady-state levels needed in doTransition( ) and
            % doMeasurement( ).
            isDelog = false;
            ssY = createTrendArray(this, v, isDelog, find(ixy), 0);
            ssXf = createTrendArray(this, v, isDelog, ...
                this.Vector.Solution{2}(1:nf), [-1, 0]);
            ssXb = createTrendArray(this, v, isDelog, ...
                this.Vector.Solution{2}(nf+1:end), [-1, 0]);
        end
        
        % __Solution Matrices__
        flagTransition = true;
        flagMeasurement = true;
        if doMeasurement
            % Measurement matrices.
            flagMeasurement = measurementEquations( );
        end
        if doTransition
            % Transition matrices.
            flagTransition = transitionEquations( );
        end
        if ~flagTransition || ~flagMeasurement
            if ~this.IsLinear && ~mychksstate(this, v)
                exitFlag(v) = -4;
                continue;
            else
                exitFlag(v) = -1;
                continue;
            end
        end
        if ny>0
            % Transformed measurement matrices.
            transformMeasurement( );
        end
        if doTransition && ahead>0
            % Expand solution matrices up to t+ahead
            vthR = this.Variant.FirstOrderSolution{2}(:, 1:ne, v);
            vthY = this.Variant.FirstOrderSolution{8}(:, 1:nh, v);
            vthExpansion = getIthFirstOrderExpansion(this.Variant, v);
            [vthR, vthY] = model.expandFirstOrder(vthR, vthY, vthExpansion, ahead);
            this.Variant.FirstOrderSolution{2}(:, :, v) = vthR;
            this.Variant.FirstOrderSolution{8}(:, :, v) = vthY;
        end
    end
    
    if opt.Progress
        update(progress, v/length(variantsRequired));
    end
end

exitFlag = exitFlag(1, variantsRequired);
nanDeriv = nanDeriv(1, variantsRequired);
sing1 = sing1(:, variantsRequired);

return


    function [SS, TT, QQ, ZZ, eqOrd, numUnitRoots, numStableRoots] = computeSchur( )
        % Ordered real QZ decomposition.
        fA = full(syst.A{2});
        fB = full(syst.B{2});
        eqOrd = 1 : size(fA, 1);
        % If the QZ re-ordering fails, change the order of equations --
        % place the first equation last, and repeat.
        wq = warning('query', 'MATLAB:ordqz:reorderingFailed');
        warning('off', 'MATLAB:ordqz:reorderingFailed');
        while true
            AA = fA(eqOrd, :);
            BB = fB(eqOrd, :);
            [SS, TT, QQ, ZZ] = qz(AA, BB, 'real');
            % Ordered inverse eigvals.
            invEigen = -ordeig(SS, TT);
            invEigen = invEigen(:).';
            isSevn2 = applySevn2Patch( );
            absInvEigen = abs(invEigen);
            indexStableRoots = absInvEigen>=(1+EIGEN_TOLERANCE);
            indexUnitRoots = abs(absInvEigen-1) < EIGEN_TOLERANCE;
            % Clusters of unit, stable, and unstable eigenvalues.
            clusters = zeros(size(invEigen));
            % Unit roots first.
            clusters(indexUnitRoots) = 2;
            % Stable roots second.
            clusters(indexStableRoots) = 1;
            % Unstable roots last.
            % Re-order by the clusters.
            lastwarn('');
            [SS, TT, QQ, ZZ] = ordqz(SS, TT, QQ, ZZ, clusters);
            isEmptyWarn = isempty(lastwarn( ));
            % If the first equations is ordered second, it indicates the
            % next cycle would bring the equations to their original order.
            % We stop and throw an error.
            if isEmptyWarn || eqOrd(2)==1
                break
            else
                eqOrd = eqOrd([2:end, 1]);
            end
        end
        warning(wq);
        if ~isEmptyWarn
            utils.error('model:mysolve', ...
                ['QZ re-ordering failed because ', ...
                'some eigenvalues are too close to swap, and ', ...
                'equation re-ordering does not help.']);
        end
        if opt.Warning && eqOrd(1)~=1
            utils.warning('model:mysolve', ...
                ['Numerical instability in QZ decomposition. ', ...
                'Equations re-ordered %g time(s).'], ...
                eqOrd(1)-1);
        end
        
        % Reorder inverse eigvals.
        invEigen = -ordeig(SS, TT);
        invEigen = invEigen(:).';
        isSevn2 = applySevn2Patch( ) | isSevn2;
        if opt.Warning && isSevn2
            utils.warning('model:mysolve', ...
                ['Numerical instability in QZ decomposition. ', ...
                'SEVN2 patch applied.'])
        end
        absInvEigen = abs(invEigen);
        indexStableRoots = absInvEigen>=(1+EIGEN_TOLERANCE);
        indexUnitRoots = abs(absInvEigen-1) < EIGEN_TOLERANCE;        
        numUnitRoots = nnz(indexUnitRoots);
        numStableRoots = nnz(indexStableRoots);
        
        % Undo eigval inversion.
        eigen = invEigen;
        ixInfEigVal = invEigen==0;
        eigen(~ixInfEigVal) = 1./invEigen(~ixInfEigVal);
        eigen(ixInfEigVal) = Inf;
        
        % Check BK saddle-path condition.
        if any(isnan(eigen))
            exitFlag(v) = -2;
        elseif nb==numStableRoots+numUnitRoots
            exitFlag(v) = 1;
        elseif nb>numStableRoots+numUnitRoots
            exitFlag(v) = 0;
        else
            exitFlag(v) = Inf;
        end
        this.Variant.EigenValues(1, :, v) = eigen;
        this.Variant.EigenStability(:, :, v) = repmat(TYPE(0), 1, numel(eigen));
        this.Variant.EigenStability(1, indexStableRoots, v) = TYPE(0);
        this.Variant.EigenStability(1, indexUnitRoots, v) = TYPE(1);
        this.Variant.EigenStability(1, ~indexStableRoots & ~indexUnitRoots, v) = TYPE(2);
        
        return
        
        
        function flag = applySevn2Patch( )
            % Sum of two eigvals near to 2 may indicate inaccuracy.
            % Largest eigval less than 1.
            flag = false;
            eigval0 = invEigen;
            eigval0(abs(invEigen)>=1-EIGEN_TOLERANCE) = 0;
            eigval0(imag(invEigen)~=0) = 0;
            if any(eigval0<=0)
                [ans, below] = max(abs(eigval0)); %#ok<*NOANS, *ASGLU>
            else
                below = [ ];
            end
            % Smallest eig greater than 1.
            eigval0 = invEigen;
            eigval0(abs(invEigen)<=1+EIGEN_TOLERANCE) = Inf;
            eigval0(imag(invEigen)~=0) = Inf;
            if any(~isinf(eigval0))
                [ans, above] = min(abs(eigval0));
            else
                above = [ ];
            end
            if ~isempty(below) && ~isempty(above) ...
                    && abs(invEigen(below) + invEigen(above) - 2)<=EIGEN_TOLERANCE ...
                    && abs(invEigen(below) - 1)<=SEVN2_TOLERANCE
                invEigen(below) = sign(invEigen(below));
                invEigen(above) = sign(invEigen(above));
                TT(below, below) = sign(TT(below, below))*abs(SS(below, below));
                TT(above, above) = sign(TT(above, above))*abs(SS(above, above));
                flag = true;
            end
        end
    end

    
    function flag = transitionEquations( )
        flag = true;
        isHash = any(ixh);
        S11 = SS(1:nb, 1:nb);
        S12 = SS(1:nb, nb+1:end);
        S22 = SS(nb+1:end, nb+1:end);
        T11 = TT(1:nb, 1:nb);
        T12 = TT(1:nb, nb+1:end);
        T22 = TT(nb+1:end, nb+1:end);
        Z11 = ZZ(indexXfToKeep, 1:nb);
        Z12 = ZZ(indexXfToKeep, nb+1:end);
        Z21 = ZZ(kf+1:end, 1:nb);
        Z22 = ZZ(kf+1:end, nb+1:end);
        
        % Transform the other system matrices by QQ.
        if eqOrd(1)==1
            % No equation re-ordering.
            % Constant.
            C = QQ*syst.K{2};
            % Effect of transition shocks.
            D = QQ*full(syst.E{2});
            if isHash
                % Effect of add-factors in transition equations earmarked
                % for nonlinear simulations.
                N = QQ*syst.N{2};
            end
        else
            % Equations have been re-ordered while computing QZ.
            % Constant.
            C = QQ*syst.K{2}(eqOrd, :);
            % Effect of transition shocks.
            D = QQ*full(syst.E{2}(eqOrd, :));
            if isHash
                % Effect of add-factors in transition equations earmarked
                % for nonlinear simulations.
                N = QQ*syst.N{2}(eqOrd, :);
            end
        end
        
        C1 = C(1:nb, 1);
        C2 = C(nb+1:end, 1);
        D1 = D(1:nb, :);
        D2 = D(nb+1:end, :);
        if isHash
            N1 = N(1:nb, :);
            N2 = N(nb+1:end, :);
        end
        
        % Quasi-triangular state-space form.
        
        U = Z21;
        
        % Singularity in the rotation matrix; something's wrong with the model
        % because this is supposed to be regular by construction.
        if rcond(U)<=SOLVE_TOLERANCE
            flag = false;
            return
        end
        
        % Steady state for nonlinear models. They are needed in nonlinear
        % models to back out the constant vectors.
        if ~this.IsLinear
            ssA = U \ ssXb;
            if any(isnan(ssA(:)))
                flag = false;
                return
            end
        end
        
        % Unstable block.
        
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
        
        if this.IsLinear
            Ku = -(S22+T22)\C2;
        else
            Ku = zeros(nf, 1);
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
        if this.IsLinear
            Ka = -(Xa0 + Xa1)*Ku - S11\C1;
        else
            Ka = ssA(:, 2) - Ta*ssA(:, 1);
        end
        if any(isnan(Ka(:)))
            flag = false;
            return
        end
        
        % Forward-looking variables.
        
        % Duplicit rows have been already deleted from Z11 and Z12.
        Tf = Z11;
        Xf = Z11*G + Z12;
        Rf = Xf*Ru;
        if isHash
            Yf = Xf*Yu;
        end
        if this.IsLinear
            Kf = Xf*Ku;
        else
            Kf = ssXf(:, 2) - Tf*ssA(:, 1);
        end
        if any(isnan(Kf(:)))
            flag = false;
            return
        end
        
        % State-space form:
        % [xf(t);a(t)] = T a(t-1) + K + R(L) e(t) + Y(L) addfactor(t), 
        % U a(t) = xb(t).
        T = [Tf;Ta];
        K = [Kf;Ka];
        R = [Rf;Ra];
        if isHash
            Y = [Yf;Ya];
        end
        
        this.Variant.FirstOrderSolution{1}(:, :, v) = T;
        this.Variant.FirstOrderSolution{2}(:, 1:ne, v) = R;
        this.Variant.FirstOrderSolution{3}(:, :, v) = K;
        this.Variant.FirstOrderSolution{7}(:, :, v) = U;
        if isHash
            this.Variant.FirstOrderSolution{8}(:, 1:nh, v) = Y;
        end
        
        if true %~opt.Fast
            % Necessary initial conditions in xb vector
            this.Variant.IxInit(:, :, v) = any(abs(T/U)>SOLVE_TOLERANCE, 1);

            % Forward expansion
            % a(t) <<< -Xa J^(k-1) Ru e(t+k)
            % xf(t) <<< Xf J^k Ru e(t+k)
            J = -T22\S22;
            Xa = Xa1 + Xa0*J;
            % Highest computed power of J: e(t+k) requires J^k.
            Jk = eye(size(J));
            
            this.Variant.FirstOrderExpansion{1}(:, :, v) = Xa;
            this.Variant.FirstOrderExpansion{2}(:, :, v) = Xf;
            this.Variant.FirstOrderExpansion{3}(:, :, v) = Ru;
            this.Variant.FirstOrderExpansion{4}(:, :, v) = J;
            if isHash
                this.Variant.FirstOrderExpansion{5}(:, :, v) = Yu;
            end
        end
    end


    function flag = measurementEquations( )
        flag = true;
        % First, create untransformed measurement equation; the transformed
        % measurement matrix will be calculated later on.
        % y(t) = ZZ xb(t) + D + H e(t)
        Zb = zeros(0, nb);
        H = zeros(0, ne);
        D = zeros(0, 1);
        if nz>0
            % Transition variables marked for measurement.
            pos = find(this.Quantity.IxObserved);
            xbVector = this.Vector.Solution{2}(nf+1:end);
            Zb = zeros(nz, nb);
            ix = bsxfun(@eq, pos(:), xbVector);
            Zb(ix) = 1;
        elseif ny>0
            % Measurement variables.
            Zb = -full(syst.A{1}\syst.B{1});
            if any(isnan(Zb(:)))
                flag = false;
                % Find singularities in measurement equations and their culprits.
                if rcond(full(syst.A{1}))<=SOLVE_TOLERANCE
                    s = size(syst.A{1}, 1);
                    r = rank(full(syst.A{1}));
                    d = s - r;
                    [u, ~] = svd(full(syst.A{1}));
                    sing1(:, v) = any( abs(u(:, end-d+1:end))>SOLVE_TOLERANCE, 2 );
                end
                return
            end
            H = -full(syst.A{1}\syst.E{1});
            if any(isnan(H(:)))
                flag = false;
                return
            end
            if this.IsLinear
                D = full(-syst.A{1}\syst.K{1});
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
    end

    
    function transformMeasurement( )
        % Transform the Zb matrix to Za:
        %     y = Zb*xb -> y = Za*alp
        Zb = this.Variant.FirstOrderSolution{9}(:, :, v);
        U = this.Variant.FirstOrderSolution{7}(:, :, v);
        Za = Zb*U;
        this.Variant.FirstOrderSolution{4}(:, :, v) = Za;
    end
end
