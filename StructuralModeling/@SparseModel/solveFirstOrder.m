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
info.ExitFlag = ones(1, nv);
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

v = 1;

% Differentiate equations and set up unsolved system matrices; check
% for NaN derivatives.
[system, info.InxNanDeriv{v}] = systemFirstOrder(this, v, opt);
if any(info.InxNanDeriv{v})
    info.ExitFlag = -3;
    return
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
    info.ExitFlag = 1i;
    return
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
    info.ExitFlag = NaN;
    return
end

info.SchurDecomposition(v) = "none";
this.Variant.EigenValues = [];
info.EigenValues{1} = [];

%
% Solution matrices
%
flagTransition = true;
flagMeasurement = true;
if doMeasurement
    flagMeasurement = hereMeasurementEquations();
end
if doTransition
    flagTransition = hereTransitionEquations();
end

if ~flagTransition || ~flagMeasurement
    info.ExitFlag = -1;
end

return

    function flag = hereTransitionEquations()
        T = -system.A{2} \ system.B{2};
        R = -system.A{2} \ system.E{2};
        K = -system.A{2} \ system.K{2};
        U = [];

        this.Variant.FirstOrderSolution{1} = [];
        this.Variant.FirstOrderSolution{2} = R;
        this.Variant.FirstOrderSolution{3} = K;
        this.Variant.FirstOrderSolution{7} = U;
        this.Variant.FirstOrderSolution{10} = T;

        flag = ~any(isnan(T(:))) && ~any(isnan(R(:))) && ~any(isnan(K(:)));

        % Necessary initial conditions in xib vector
        this.Variant.IxInit(:, :, v) = any(abs(T)>SOLVE_TOLERANCE, 1);
    end%


    function flag = hereMeasurementEquations( )
        flag = true;
        % First, create untransformed measurement equation; the transformed
        % measurement matrix will be calculated later on.
        % y(t) = ZZ xib(t) + D + H e(t)
        Zb = sparse(0, numXib);
        H = sparse(0, numE);
        D = sparse(0, 1);
        if numZ>0
            % Transition variables marked for measurement
            pos = find(this.Quantity.IxObserved);
            xibVector = this.Vector.Solution{2}(numXif+1:end);
            Zb = sparse(numZ, numXib);
            inx = bsxfun(@eq, pos(:), xibVector);
            Zb(inx) = 1;
        elseif numY>0
            % Measurement variables
            Zb = -(system.A{1}\system.B{1});
            if any(isnan(Zb(:)))
                flag = false;
                return
            end
            H = -(system.A{1}\system.E{1});
            if any(isnan(H(:)))
                flag = false;
                return
            end
            D = (-system.A{1}\system.K{1});
            if any(isnan(D(:)))
                flag = false;
                return
            end
        end
        this.Variant.FirstOrderSolution{4} = Zb;
        this.Variant.FirstOrderSolution{5} = H;
        this.Variant.FirstOrderSolution{6} = D;
    end%
end

%
% Local functions
%

function [eigenStability, bk, exitFlag] = locallyVerifyStability(eigenValues, numXib, tolerance)
    %(
    absEigen = abs(eigenValues);
    inxStableRoots = absEigen<=(1-tolerance);
    inxUnitRoots = abs(absEigen-1)<tolerance;
    numUnitRoots = nnz(inxUnitRoots);
    numStableRoots = nnz(inxStableRoots);


    % Check BK saddle-path condition

    if any(isnan(eigenValues))
        exitFlag = -2;
    elseif numXib==numStableRoots+numUnitRoots
        exitFlag = 1;
    elseif numXib>numStableRoots+numUnitRoots
        exitFlag = 0;
    else
        exitFlag = Inf;
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

function T = locallyComputePlainInversion(system, tolerance)
    %(
    %)
end%

