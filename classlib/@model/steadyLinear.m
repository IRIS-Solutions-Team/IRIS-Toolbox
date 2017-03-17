function  [this, ixSuccess, nPath, eigen] = steadyLinear(this, steady, vecAlt)
% steadyLinear  Calculate steady state in linear models.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

EIGEN_TOLERANCE = this.Tolerance.Eigen;
STEADY_TOLERANCE = this.Tolerance.Steady;
TYPE = @int8;
PTR = @int16;

try
    isWarn = isequal(steady.Warning, true);
catch %#ok<CTCH>
    isWarn = true;
end

vecAlt = vecAlt(:).';

%--------------------------------------------------------------------------

nPath = [ ];
eigen = [ ];
if ~isequal(steady.Solve, false)
    % Solve the model first if requested by the user.
    solveOpt = prepareSolve(this, 'verbose', steady.Solve);    
    [this, nPath, eigen] = solve(this, solveOpt);
end

nAlt = length(this.Variant);
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
    this = refresh(this, vecAlt);
end

[~, ixNanSolution] = isnan(this, 'solution');
ixSolution = true(1, nAlt);
ixSolution(vecAlt) = ~ixNanSolution(vecAlt);
if isWarn && any(~ixSolution)
    throw( ...
        exception.Base('Model:CannotSteadyLinear', 'warning'), ...
        exception.Base.alt2str(~ixSolution) ...
        ); %#ok<GTARG>
end

ixSuccess = false(1, nAlt);
ixDiffStat = true(1, nAlt);
for iAlt = vecAlt
    lvl = nan(1, nQty);
    grw = zeros(1, nQty);
    if ixSolution(iAlt)
        [lvl, grw, ixDiffStat(iAlt)] = getSstate( );
        if any(ixLog)
            lvl(1, ixLog) = real(exp(lvl(1, ixLog)));
            grw(1, ixLog) = real(exp(grw(1, ixLog)));
        end
        ixSuccess(iAlt) = true;
    end
    % Assign the values to the model object, measurement and transition
    % variables only.
    this.Variant{iAlt}.Quantity(1, ixyx) = lvl(1, ixyx) + 1i*grw(1, ixyx);
    this.Variant{iAlt}.Quantity(1, ixe) = 0;
end

% Some parameterizations are not difference stationary.
if ~any(ixDiffStat)
    throw( ...
        exception.Base('Model:NotDifferenceStationary', 'warning'), ...
        exception.Base.alt2str(ixDiffStat) ...
        ); %#ok<GTARG>
end

if needsRefresh
    this = refresh(this, vecAlt);
end

return




    function [lvl, grw, isDiffStat] = getSstate( )
        T = this.solution{1}(:, :, iAlt);
        K = this.solution{3}(:, :, iAlt);
        Z = this.solution{4}(:, :, iAlt);
        D = this.solution{6}(:, :, iAlt);
        U = this.solution{7}(:, :, iAlt);
        [nx, nb] = size(T);
        nUnit = sum(this.Variant{iAlt}.Stability==TYPE(1));
        nf = nx - nb;
        nStable = nb - nUnit;
        Tf = T(1:nf, :);
        Ta = T(nf+1:end, :);
        Kf = K(1:nf, 1);
        Ka = K(nf+1:end, 1);
        
        % Alpha vector
        %--------------
        isDiffStat = all(all(abs(Ta(1:nUnit,1:nUnit)-eye(nUnit))<EIGEN_TOLERANCE));
        if isDiffStat
            % I(0) or I(1) systems (stationary or difference stationary).
            a2 = (eye(nStable) - Ta(nUnit+1:end,nUnit+1:end)) ...
                \ Ka(nUnit+1:end, 1);
            da1 = Ta(1:nUnit, nUnit+1:end)*a2 + Ka(1:nUnit, 1);
        else
            % I(2) or higher-order systems. Write the steady-state system at two
            % different times: t and t+d.
            d = 10;
            E1 = [eye(nb), zeros(nb); eye(nb), d*eye(nb)];
            E2 = [Ta, -Ta; Ta, (d-1)*Ta];
            temp = pinv(E1 - E2) * [Ka; Ka];
            a2 = temp(nUnit+(1:nStable));
            da1 = temp(nb+(1:nUnit));
        end
        
        % Transition variables
        %----------------------
        x = [ Tf*[-da1; a2]+Kf; U(:, nUnit+1:end)*a2 ];
        dx = [ Tf(:, 1:nUnit)*da1; U(:, 1:nUnit)*da1 ];
        x( abs(x)<=STEADY_TOLERANCE ) = 0;
        dx( abs(dx)<=STEADY_TOLERANCE ) = 0;
        x(~ixZeroShxx) = [ ];
        dx(~ixZeroShxx) = [ ];
        lvl(1, posxx) = x(:).';
        grw(1, posxx) = dx(:).';
        
        % Measurement variables
        %-----------------------
        if ny > 0
            y = Z(:, nUnit+1:end)*a2 + D;
            dy = Z(:, 1:nUnit)*da1;
            lvl(1, posy) = y(:).';
            grw(1, posy) = dy(:).';
        end
    end
end
