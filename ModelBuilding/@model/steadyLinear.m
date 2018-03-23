function  [this, ixSuccess, nPath, eigen] = steadyLinear(this, steady, variantsRequested)
% steadyLinear  Calculate steady state in linear models
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

EIGEN_TOLERANCE = this.Tolerance.Eigen;
STEADY_TOLERANCE = this.Tolerance.Steady;
TYPE = @int8;
PTR = @int16;

try
    isWarn = isequal(steady.Warning, true);
catch %#ok<CTCH>
    isWarn = true;
end

nv = length(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
else
    variantsRequested = variantsRequested(:).';
end

%--------------------------------------------------------------------------

nPath = [ ];
eigen = [ ];
if ~isequal(steady.Solve, false)
    % Solve the model first if requested by the user.
    solveOpt = prepareSolve(this, 'verbose', steady.Solve);    
    [this, nPath, eigen] = solve(this, solveOpt);
end

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
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
if isWarn && any(~ixSolution)
    throw( ...
        exception.Base('Model:CannotSteadyLinear', 'warning'), ...
        exception.Base.alt2str(~ixSolution) ...
        ); %#ok<GTARG>
end

ixSuccess = false(1, nv);
ixDiffStat = true(1, nv);
for v = variantsRequested
    lvl = nan(1, nQty);
    grw = zeros(1, nQty);
    if ixSolution(v)
        [lvl, grw, ixDiffStat(v)] = getSteady( );
        if any(ixLog)
            lvl(1, ixLog) = real(exp(lvl(1, ixLog)));
            grw(1, ixLog) = real(exp(grw(1, ixLog)));
        end
        ixSuccess(v) = true;
    end
    % Assign the values to the model object, measurement and transition
    % variables only.
    this.Variant.Values(:, ixyx, v) = lvl(1, ixyx) + 1i*grw(1, ixyx);
    this.Variant.Values(:, ixe, v) = 0;
end

% Some parameterizations are not difference stationary.
if ~any(ixDiffStat)
    throw( ...
        exception.Base('Model:NotDifferenceStationary', 'warning'), ...
        exception.Base.alt2str(ixDiffStat) ...
        ); %#ok<GTARG>
end

if needsRefresh
    this = refresh(this, variantsRequested);
end

return


    function [lvl, grw, isDiffStat] = getSteady( )
        [T, ~, K, Z, ~, D, U] = sspaceMatrices(this, v);
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
    end
end
