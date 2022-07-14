% steadyLinear  Calculate steady state in linear models
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function  [this, success, outputInfo] = steadyLinear(this, variantsRequested, options)

EIGEN_TOLERANCE = this.Tolerance.Eigen;
STEADY_TOLERANCE = this.Tolerance.Steady;
PTR = @int16;

try
    throwWarning = isequal(options.Warning, true);
catch %#ok<CTCH>
    throwWarning = true;
end

nv = countVariants(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
else
    variantsRequested = variantsRequested(:).';
end

%--------------------------------------------------------------------------

outputInfo = struct( );
outputInfo.NumOfPaths = [ ];
outputInfo.EigenValues = [ ];

if options.Solve.Run
    hereSolveModel( );
end

ixy = this.Quantity.Type==1;
ixx = this.Quantity.Type==2;
ixe = this.Quantity.Type==31 | this.Quantity.Type==32;
ixyx = ixy | ixx;
ny = sum(ixy);
ixLog = this.Quantity.IxLog;
needsRefresh = any(this.Link);
nQty = length(this.Quantity);
posy = real(this.Vector.Solution{1});
posxx = real(this.Vector.Solution{2});
shxx = imag(this.Vector.Solution{2});
ixZeroShxx = shxx==0;
posxx(~ixZeroShxx) = [ ];

if needsRefresh
    this = refresh(this, variantsRequested);
end

[~, ixNanSolution] = isnan(this, 'solution');
ixSolution = true(1, nv);
ixSolution(variantsRequested) = ~ixNanSolution(variantsRequested);
if throwWarning && any(~ixSolution)
    throw( ...
        exception.Base('Model:CannotSteadyLinear', 'warning'), ...
        exception.Base.alt2str(~ixSolution) ...
        ); %#ok<GTARG>
end

success = false(1, nv);
ixDiffStat = true(1, nv);
for v = variantsRequested
    lvl = nan(1, nQty);
    grw = zeros(1, nQty);
    if ixSolution(v)
        [lvl, grw, ixDiffStat(v)] = hereGetSteady( );
        if any(ixLog)
            lvl(1, ixLog) = real(exp(lvl(1, ixLog)));
            grw(1, ixLog) = real(exp(grw(1, ixLog)));
        end
        success(v) = true;
    end
    % Assign the values to the model object, measurement and transition
    % variables only
    this.Variant.Values(:, ixyx, v) = lvl(1, ixyx) + 1i*grw(1, ixyx);
    this.Variant.Values(:, ixe, v) = 0;
end

% Some parameterizations are not difference stationary
if ~any(ixDiffStat)
    throw( exception.Base('Model:NotDifferenceStationary', 'warning'), ...
           exception.Base.alt2str(ixDiffStat) ); %#ok<GTARG>
end

if needsRefresh
    this = refresh(this, variantsRequested);
end

% Reset steady state for time trend
pos = locateTrendLine(this.Quantity, NaN);
this.Variant.Values(1, pos, :) = complex(0, 1);

return


    function hereSolveModel( )
        [this, numOfPaths, eigenValues] = solve(this, options.Solve{:});
        outputInfo.NumOfPaths = numOfPaths;
        outputInfo.EigenValues = eigenValues;
    end%


    function [lvl, grw, isDiffStat] = hereGetSteady( )
        [T, ~, K, Z, ~, D, U] = getSolutionMatrices(this, v);
        [nx, nb] = size(T);
        numOfUnitRoots = getNumOfUnitRoots(this.Variant, v);
        nf = nx - nb;
        numOfStableRoots = nb - numOfUnitRoots;
        Tf = T(1:nf, :);
        Ta = T(nf+1:end, :);
        Kf = K(1:nf, 1);
        Ka = K(nf+1:end, 1);

        % __Alpha Vector__
        isDiffStat = all(all(abs(Ta(1:numOfUnitRoots,1:numOfUnitRoots)-eye(numOfUnitRoots))<EIGEN_TOLERANCE));
        if isDiffStat
            % I(0) or I(1) systems (stationary or difference stationary)
            a2 = (eye(numOfStableRoots) - Ta(numOfUnitRoots+1:end,numOfUnitRoots+1:end)) ...
                \ Ka(numOfUnitRoots+1:end, 1);
            da1 = Ta(1:numOfUnitRoots, numOfUnitRoots+1:end)*a2 + Ka(1:numOfUnitRoots, 1);
        else
            % I(2) or higher-order systems. Write the steady-state system at two
            % different times: t and t+d
            d = 10;
            E1 = [eye(nb), zeros(nb); eye(nb), d*eye(nb)];
            E2 = [Ta, -Ta; Ta, (d-1)*Ta];
            temp = pinv(E1 - E2) * [Ka; Ka];
            a2 = temp(numOfUnitRoots+(1:numOfStableRoots));
            da1 = temp(nb+(1:numOfUnitRoots));
        end
        
        % __Transition Variables__
        x = [ Tf*[-da1; a2]+Kf; U(:, numOfUnitRoots+1:end)*a2 ];
        dx = [ Tf(:, 1:numOfUnitRoots)*da1; U(:, 1:numOfUnitRoots)*da1 ];
        x( abs(x)<=STEADY_TOLERANCE ) = 0;
        dx( abs(dx)<=STEADY_TOLERANCE ) = 0;
        x(~ixZeroShxx) = [ ];
        dx(~ixZeroShxx) = [ ];
        lvl(1, posxx) = x(:).';
        grw(1, posxx) = dx(:).';
        
        % __Measurement Variables__
        if ny > 0
            y = Z(:, numOfUnitRoots+1:end)*a2 + D;
            dy = Z(:, 1:numOfUnitRoots)*da1;
            lvl(1, posy) = y(:).';
            grw(1, posy) = dy(:).';
        end
    end%
end%

