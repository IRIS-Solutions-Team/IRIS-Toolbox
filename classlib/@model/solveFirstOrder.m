function [this, nPath, nanDeriv, sing1, bk] = solveFirstOrder(this, vecAlt, opt)
% solveFirstOrder  First-order quasi-triangular solution.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% NPath
%
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

doT = true; % Do transition equations.
doM = true; % Do measurement equations.
if strcmpi(opt.eqtn, 'transition')
    doT = true;
    doM = false;
elseif strcmpi(opt.eqtn, 'measurement')
    doT = false;
    doM = true;
end

ixy = this.Quantity.Type==int8(1);
ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32);
ixt = this.Equation.Type==1;
ixh = this.Equation.IxHash;
nh = sum(ixh);
nt = sum(ixt);

ny = sum(ixy);
ne = sum(ixe);
[ny, nxi, nb, nf, ne] = sizeOfSolution(this.Vector);
kxi = length(this.Vector.System{2});
kf = kxi - nb; % Fwl in system.
ixFKeep = ~this.d2s.remove;
nAlt = length(this);
if isequal(vecAlt, Inf)
    vecAlt = 1 : nAlt;
end
nVecAlt = length(vecAlt);

% Reset icondix, eigenvalues, solution matrices, expansion matrices
% depending on `isTransition` and `isMeasurement`.
reset( );

% Set `NPATH` to 1 initially to handle correctly the cases when only a
% subset of parameterisations is solved for.
nPath = ones(1, nAlt);
sing1 = false(nt, nAlt);
nanDeriv = cell(1, nAlt);
bk = nan(3, nAlt);

if opt.progress
    progress = ProgressBar('IRIS model.solve progress');
end

for iAlt = vecAlt(:).'

    % Differentiate equations and set up unsolved system matrices; check
    % for NaN derivatives.
    [syst, nanDeriv{iAlt}] = systemFirstOrder(this, iAlt, opt);
    if any(nanDeriv{iAlt})
        nPath(iAlt) = -3;
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
        nPath(iAlt) = 1i;
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
        nPath(iAlt) = NaN;
        continue;
    end
    
    % Schur decomposition and saddle-path check
    %-------------------------------------------
    if doT
        [SS, TT, QQ, ZZ, eqOrd, nUnit, nStable] = computeSchur( );
        bk(:, iAlt) = [nb; nUnit; nStable] ;
    end
    
    if nPath(iAlt)==1
        if ~opt.linear
            % Steady-state levels needed in doTransition( ) and
            % doMeasurement( ).
            isDelog = false;
            ssY = createTrendArray(this, iAlt, isDelog, find(ixy), 0);
            ssXf = createTrendArray(this, iAlt, isDelog, ...
                this.Vector.Solution{2}(1:nf), [-1, 0]);
            ssXb = createTrendArray(this, iAlt, isDelog, ...
                this.Vector.Solution{2}(nf+1:end), [-1, 0]);
        end
        
        % Solution matrices
        %-------------------
        flagTrans = true;
        flagMeas = true;
        if doM
            % Measurement matrices.
            flagMeas = measurementEquations( );
        end
        if doT
            % Transition matrices.
            flagTrans = transitionEquations( );
        end
        if ~flagTrans || ~flagMeas
            if ~this.IsLinear && ~mychksstate(this, iAlt)
                nPath(iAlt) = -4;
                continue;
            else
                nPath(iAlt) = -1;
                continue;
            end
        end
        % Transformed measurement matrices.
        transformMeasurement( );
        
        % Forward expansion of solution matrices
        %----------------------------------------
        if doT && opt.expand>0
            [newR, newY, newJk] = model.myexpand( ...
                this.solution{2}(:, :, iAlt), ...
                this.solution{8}(:, :, iAlt), ...
                opt.expand, ...
                this.Expand{1}(:, :, iAlt), ...
                this.Expand{2}(:, :, iAlt), ...
                this.Expand{3}(:, :, iAlt), ...
                this.Expand{4}(:, :, iAlt), ...
                this.Expand{5}(:, :, iAlt), ...
                this.Expand{6}(:, :, iAlt));
            this.solution{2}(:, :, iAlt) = newR;
            this.solution{8}(:, :, iAlt) = newY;
            this.Expand{5}(:, :, iAlt) = newJk;
        end        
    end
    
    if opt.progress
        update(progress, iAlt/length(vecAlt));
    end

end

nPath = nPath(1, vecAlt);
nanDeriv = nanDeriv(1, vecAlt);
sing1 = sing1(:, vecAlt);

return



    function [SS, TT, QQ, ZZ, eqOrd, nUnit, nStable] = computeSchur( )
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
            ixStable = absInvEigen >= (1+EIGEN_TOLERANCE);
            ixUnit = abs(absInvEigen-1) < EIGEN_TOLERANCE;
            % Clusters of unit, stable, and unstable eigenvalues.
            clusters = zeros(size(invEigen));
            % Unit roots first.
            clusters(ixUnit) = 2;
            % Stable roots second.
            clusters(ixStable) = 1;
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
        if opt.warning && eqOrd(1) ~= 1
            utils.warning('model:mysolve', ...
                ['Numerical instability in QZ decomposition. ', ...
                'Equations re-ordered %g time(s).'], ...
                eqOrd(1)-1);
        end
        
        % Reorder inverse eigvals.
        invEigen = -ordeig(SS, TT);
        invEigen = invEigen(:).';
        isSevn2 = applySevn2Patch( ) | isSevn2;
        if opt.warning && isSevn2
            utils.warning('model:mysolve', ...
                ['Numerical instability in QZ decomposition. ', ...
                'SEVN2 patch applied.'])
        end
        absInvEigen = abs(invEigen);
        ixStable = absInvEigen >= (1+EIGEN_TOLERANCE);
        ixUnit = abs(absInvEigen-1) < EIGEN_TOLERANCE;        
        nUnit = sum(ixUnit);
        nStable = sum(ixStable);
        
        % Undo eigval inversion.
        eigen = invEigen;
        ixInfEigVal = invEigen==0;
        eigen(~ixInfEigVal) = 1./invEigen(~ixInfEigVal);
        eigen(ixInfEigVal) = Inf;
        
        % Check BK saddle-path condition.
        if any(isnan(eigen))
            nPath(iAlt) = -2;
        elseif nb==nStable+nUnit
            nPath(iAlt) = 1;
        elseif nb>nStable+nUnit
            nPath(iAlt) = 0;
        else
            nPath(iAlt) = Inf;
        end
        this.Variant{iAlt}.Eigen(1, :) = eigen;
        this.Variant{iAlt}.Stability = repmat(TYPE(0), 1, numel(eigen));
        this.Variant{iAlt}.Stability(1, ixStable) = TYPE(0);
        this.Variant{iAlt}.Stability(1, ixUnit) = TYPE(1);
        this.Variant{iAlt}.Stability(1, ~ixStable & ~ixUnit) = TYPE(2);
        
        return
        
        
        
        
        function Flag = applySevn2Patch( )
            % Sum of two eigvals near to 2 may indicate inaccuracy.
            % Largest eigval less than 1.
            Flag = false;
            eigval0 = invEigen;
            eigval0(abs(invEigen) >= 1-EIGEN_TOLERANCE) = 0;
            eigval0(imag(invEigen) ~= 0) = 0;
            if any(eigval0 ~= 0)
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
                    && abs(invEigen(below) + invEigen(above) - 2) <= EIGEN_TOLERANCE ...
                    && abs(invEigen(below) - 1) <= SEVN2_TOLERANCE
                invEigen(below) = sign(invEigen(below));
                invEigen(above) = sign(invEigen(above));
                TT(below, below) = sign(TT(below, below))*abs(SS(below, below));
                TT(above, above) = sign(TT(above, above))*abs(SS(above, above));
                Flag = true;
            end
        end
    end

    

    
    function Flag = transitionEquations( )
        Flag = true;
        isNonlin = any(ixh);
        S11 = SS(1:nb, 1:nb);
        S12 = SS(1:nb, nb+1:end);
        S22 = SS(nb+1:end, nb+1:end);
        T11 = TT(1:nb, 1:nb);
        T12 = TT(1:nb, nb+1:end);
        T22 = TT(nb+1:end, nb+1:end);
        Z11 = ZZ(ixFKeep, 1:nb);
        Z12 = ZZ(ixFKeep, nb+1:end);
        Z21 = ZZ(kf+1:end, 1:nb);
        Z22 = ZZ(kf+1:end, nb+1:end);
        
        % Transform the other system matrices by QQ.
        if eqOrd(1)==1
            % No equation re-ordering.
            % Constant.
            C = QQ*syst.K{2};
            % Effect of transition shocks.
            D = QQ*full(syst.E{2});
            if isNonlin
                % Effect of add-factors in transition equations earmarked
                % for non-linear simulations.
                N = QQ*syst.N{2};
            end
        else
            % Equations have been re-ordered while computing QZ.
            % Constant.
            C = QQ*syst.K{2}(eqOrd, :);
            % Effect of transition shocks.
            D = QQ*full(syst.E{2}(eqOrd, :));
            if isNonlin
                % Effect of add-factors in transition equations earmarked
                % for non-linear simulations.
                N = QQ*syst.N{2}(eqOrd, :);
            end
        end
        
        C1 = C(1:nb, 1);
        C2 = C(nb+1:end, 1);
        D1 = D(1:nb, :);
        D2 = D(nb+1:end, :);
        if isNonlin
            N1 = N(1:nb, :);
            N2 = N(nb+1:end, :);
        end
        
        % Quasi-triangular state-space form.
        
        U = Z21;
        
        % Singularity in the rotation matrix; something's wrong with the model
        % because this is supposed to be regular by construction.
        if rcond(U)<=SOLVE_TOLERANCE
            Flag = false;
            return
        end
        
        % Steady state for non-linear models. They are needed in non-linear
        % models to back out the constant vectors.
        if ~opt.linear
            ssA = U \ ssXb;
            if any(isnan(ssA(:)))
                Flag = false;
                return
            end
        end
        
        % Unstable block.
        
        G = -Z21\Z22;
        if any(isnan(G(:)))
            Flag = false;
            return
        end
        
        Ru = -T22\D2;
        if any(isnan(Ru(:)))
            Flag = false;
            return
        end
        
        if isNonlin
            Yu = -T22\N2;
            if any(isnan(Yu(:)))
                Flag = false;
                return
            end
        end
        
        if opt.linear
            Ku = -(S22+T22)\C2;
        else
            Ku = zeros(nf, 1);
        end
        if any(isnan(Ku(:)))
            Flag = false;
            return
        end
        
        % Transform stable block==transform backward-looking variables:
        % a(t) = s(t) + G u(t+1).
        
        Ta = -S11\T11;
        if any(isnan(Ta(:)))
            Flag = false;
            return
        end
        Xa0 = S11\(T11*G + T12);
        if any(isnan(Xa0(:)))
            Flag = false;
            return
        end
        
        Ra = -Xa0*Ru - S11\D1;
        if any(isnan(Ra(:)))
            Flag = false;
            return
        end
        
        if isNonlin
            Ya = -Xa0*Yu - S11\N1;
            if any(isnan(Ya(:)))
                Flag = false;
                return
            end
        end
        
        Xa1 = G + S11\S12;
        if any(isnan(Xa1(:)))
            Flag = false;
            return
        end
        if opt.linear
            Ka = -(Xa0 + Xa1)*Ku - S11\C1;
        else
            Ka = ssA(:, 2) - Ta*ssA(:, 1);
        end
        if any(isnan(Ka(:)))
            Flag = false;
            return
        end
        
        % Forward-looking variables.
        
        % Duplicit rows have been already deleted from Z11 and Z12.
        Tf = Z11;
        Xf = Z11*G + Z12;
        Rf = Xf*Ru;
        if isNonlin
            Yf = Xf*Yu;
        end
        if opt.linear
            Kf = Xf*Ku;
        else
            Kf = ssXf(:, 2) - Tf*ssA(:, 1);
        end
        if any(isnan(Kf(:)))
            Flag = false;
            return
        end
        
        % State-space form:
        % [xf(t);a(t)] = T a(t-1) + K + R(L) e(t) + Y(L) addfactor(t), 
        % U a(t) = xb(t).
        T = [Tf;Ta];
        K = [Kf;Ka];
        R = [Rf;Ra];
        if isNonlin
            Y = [Yf;Ya];
        end
        
        this.solution{1}(:, :, iAlt) = T;
        this.solution{2}(:, 1:ne, iAlt) = R;
        this.solution{3}(:, :, iAlt) = K;
        this.solution{7}(:, :, iAlt) = U;
        if isNonlin
            this.solution{8}(:, 1:nh, iAlt) = Y;
        end
        
        % Necessary initial conditions in xb vector.
        if ~opt.fast
            this.Variant{iAlt}.IxInit = any(abs(T/U)>SOLVE_TOLERANCE, 1);
        end
        
        if ~isempty(this.Expand)
            % Forward expansion.
            % a(t) <- -Xa J^(k-1) Ru e(t+k)
            % xf(t) <- Xf J^k Ru e(t+k)
            J = -T22\S22;
            Xa = Xa1 + Xa0*J;
            % Highest computed power of J: e(t+k) requires J^k.
            Jk = eye(size(J));
            
            this.Expand{1}(:, :, iAlt) = Xa;
            this.Expand{2}(:, :, iAlt) = Xf;
            this.Expand{3}(:, :, iAlt) = Ru;
            this.Expand{4}(:, :, iAlt) = J;
            this.Expand{5}(:, :, iAlt) = Jk;
            if isNonlin
                this.Expand{6}(:, :, iAlt) = Yu;
            end
        end
    end

    
    

    function Flag = measurementEquations( )
        Flag = true;
        % First, create untransformed measurement equation; the transformed
        % measurement matrix will be calculated later on.
        % y(t) = ZZ xb(t) + D + H e(t)
        if ny>0
            Zb = -full(syst.A{1}\syst.B{1});
            if any(isnan(Zb(:)))
                Flag = false;
                % Find singularities in measurement equations and their culprits.
                if rcond(full(syst.A{1}))<=SOLVE_TOLERANCE
                    s = size(syst.A{1}, 1);
                    r = rank(full(syst.A{1}));
                    d = s - r;
                    [u, ~] = svd(full(syst.A{1}));
                    sing1(:, iAlt) = any( abs(u(:, end-d+1:end))>SOLVE_TOLERANCE, 2 );
                end
                return
            end
            H = -full(syst.A{1}\syst.E{1});
            if any(isnan(H(:)))
                Flag = false;
                return
            end
            if opt.linear
                D = full(-syst.A{1}\syst.K{1});
            else
                D = ssY - Zb*ssXb(:, 2);
            end
            if any(isnan(D(:)))
                Flag = false;
                return
            end
        else
            Zb = zeros(0, nb);
            H = zeros(0, ne);
            D = zeros(0, 1);
        end
        % This.solution{4}(:, :, iAlt) is assigned later on.
        this.solution{5}(:, :, iAlt) = H;
        this.solution{6}(:, :, iAlt) = D;
        this.solution{9}(:, :, iAlt) = Zb;
    end

    

    
    function transformMeasurement( )
        % Transform the Zb matrix to Z:
        %     y = Zb*xb -> y = Z*alp
        Zb = this.solution{9}(:, :, iAlt);
        U = this.solution{7}(:, :, iAlt);
        Z = Zb*U;
        this.solution{4}(:, :, iAlt) = Z;
    end

    


    function reset( )
        nExpand = opt.expand;
        if isempty(this.solution) || isempty(this.solution{1})
            % Preallocate nonexisting solution matrices.
            % Transition matrices.
            this.solution{1} = nan(nxi, nb, nAlt); % T
            this.solution{2} = nan(nxi, ne*(nExpand+1), nAlt); % R
            this.solution{3} = nan(nxi, 1, nAlt); % K
            % Measurement matrices.
            this.solution{4} = nan(ny, nb, nAlt); % Z
            this.solution{5} = nan(ny, ne, nAlt); % H
            this.solution{6} = nan(ny, 1, nAlt); % D
            % Transformation of the alpha vector.
            this.solution{7} = nan(nb, nb, nAlt); % U
            % Effect of nonlinearirities.
            this.solution{8} = nan(nxi, nh*(nExpand+1), nAlt); % Y
            % Auxiliary measurement matrix y = Zb*xb;
            this.solution{9} = nan(ny, nb, nAlt); % Zb
        end
                    
        if opt.fast && opt.expand==0
            % Do not compute expansion matrices (fast calls to mysolve with
            % no expansion requested); assign an empty cell.
            this.Expand = { };
        elseif isempty(this.Expand) || isempty(this.Expand{1})
            % Preallocate nonexisting expansion matrices.
            this.Expand{1} = nan(nb, kf, nAlt);
            this.Expand{2} = nan(nf, kf, nAlt);
            this.Expand{3} = nan(kf, ne, nAlt);
            this.Expand{4} = nan(kf, kf, nAlt);
            this.Expand{5} = nan(kf, kf, nAlt);
            this.Expand{6} = nan(kf, nh, nAlt);
        end
        
        nVecAlt = length(vecAlt);
        if doT            
            % Reset transition properties.
            this.solution{1}(:, :, vecAlt) = nan(nxi, nb, nVecAlt);
            n = size(this.solution{2}, 2);
            if n<ne*(nExpand+1)
                this.solution{2} = [this.solution{2}, ...
                    nan(nxi, ne*(nExpand+1)-n, nAlt)];
                n = ne*(nExpand+1);
            end
            this.solution{2}(:, :, vecAlt) = nan(nxi, n, nVecAlt);
            this.solution{3}(:, :, vecAlt) = nan(nxi, 1, nVecAlt);
            this.solution{7}(:, :, vecAlt) = nan(nb, nb, nVecAlt);
            n = size(this.solution{8}, 2);
            if n<nh*(nExpand+1)
                this.solution{8}(:, end+1:nh*(nExpand+1), :) = NaN;
                this.solution{8} = [this.solution{8}, ...
                    nan(nxi, nh*(nExpand+1)-n, nAlt)];
                n = nh*(nExpand+1);
            end
            this.solution{8}(:, :, vecAlt) = nan(nxi, n, nVecAlt);
            
            for iiAlt = vecAlt
                this.Variant{iiAlt} = ...
                    resetTransition(this.Variant{iiAlt}, this.Vector, nExpand, nh);            
            end
            
            % Reset expansion matrices.
            if ~isempty(this.Expand) && kf>0
                this.Expand{1}(:, :, vecAlt) = NaN;
                this.Expand{2}(:, :, vecAlt) = NaN;
                this.Expand{3}(:, :, vecAlt) = NaN;
                this.Expand{4}(:, :, vecAlt) = NaN;
                this.Expand{5}(:, :, vecAlt) = NaN;
                this.Expand{6}(:, :, vecAlt) = NaN;
            end
        end
        
        if doM
            % Reset measurement properties.
            this.solution{5}(:, :, vecAlt) = nan(ny, ne, nVecAlt);
            this.solution{6}(:, :, vecAlt) = nan(ny, 1, nVecAlt);
            this.solution{9}(:, :, vecAlt) = nan(ny, nb, nAlt);
            for iiAlt = vecAlt
                this.Variant{iiAlt} = ...
                    resetMeasurement(this.Variant{iiAlt}, this.Vector);
            end
        end
        
        % Reset this.solution{4} no matter what: it depends both on
        % transition and measurement parameters and needs to be always
        % updated.
        this.solution{4}(:, :, vecAlt) = nan(ny, nb, nVecAlt);
    end
end
