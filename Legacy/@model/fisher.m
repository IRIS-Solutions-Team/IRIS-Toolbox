function [F, FF, delta, freq, G, step] = fisher(this, numPeriods, listParameters, varargin)

persistent ip
if isempty(ip)
    isnumericscalar = @(x) isnumeric(x) && isscalar(x);
    ip = inputParser(); 
    addParameter(ip, 'chksgf', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'CheckSteady', true, @model.validateChksstate);
    addParameter(ip, 'Deviation', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'epspower', 1/3, isnumericscalar);
    addParameter(ip, 'Exclude', { }, @(x) isstring(x) || ischar(x) || iscellstr(x));
    addParameter(ip, 'percent', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'progress', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'Solve', true, @model.validateSolve);
    addParameter(ip, 'Steady', false, @model.validateSteady);
    addParameter(ip, 'tolerance', eps( )^(2/3), isnumericscalar);
end
parse(ip, varargin{:});
opt = ip.Results;


ixy = this.Quantity.Type==1;
[ny, ~, ~, nf, ne] = sizeSolution(this.Vector);
nv = countVariants(this);

% Process the Exclude option.
inxToExclude = false(ny, 1);
if ~isempty(opt.Exclude)
    inxToExclude = ismember( ...
        textual.stringify(this.Quantity.Name(ixy)) ...
        , textual.stringify(opt.Exclude) ...
    );
end

% Get parameter cellstr list from a char list.
listParameters = cellstr(listParameters);

EPSILON = eps( )^opt.epspower;

ny = ny - nnz(inxToExclude);
if ny==0
    utils.warning('model:fisher', ...
        'No measurement variables included in computing Fisher matrix.');
end

ixYLog = this.Quantity.IxLog(ixy);
ixYLog(inxToExclude) = [ ];

ell = lookup(this.Quantity, listParameters, 4);
posValues = ell.PosName;
posStdCorr = ell.PosStdCorr;
inxNaPosValues = isnan(posValues);
inxNaPosStdCorr = isnan(posStdCorr);
inxValidNames = ~inxNaPosValues | ~inxNaPosStdCorr;
if any(~inxValidNames)
    utils.error('model:fisher', ...
        'This is not a valid parameter name: %s ', ...
        listParameters{~inxValidNames});
end

this.Update = this.EMPTY_UPDATE;
this.Update.Values = this.Variant.Values;
this.Update.StdCorr = this.Variant.StdCorr;
this.Update.PosOfValues = posValues;
this.Update.PosOfStdCorr = posStdCorr;

if islogical(opt.Steady)
    opt.Steady = {"run", opt.Steady};
end
this.Update.Steady = prepareSteady(this, opt.Steady{:}, "silent", true);

if islogical(opt.CheckSteady)
    opt.CheckSteady = {"run", opt.CheckSteady};
end
this.Update.CheckSteady = prepareCheckSteady(this, opt.CheckSteady{:}, "silent", true);

if islogical(opt.Solve)
    opt.Solve = {"run", opt.Solve};
end
this.Update.Solve = prepareSolve(this, opt.Solve{:}, "silent", true);

this.Update.NoSolution = 'Error';

numParameters = length(listParameters);
numFreq = floor(numPeriods/2) + 1;
freq = 2*pi*(0 : numFreq-1)/numPeriods;

% Kronecker delta vector.
% Different for even or odd number of periods.
delta = ones(1, numFreq);
if mod(numPeriods, 2)==0
    delta(2:end-1) = 2;
else
    delta(2:end) = 2;
end

FF = nan(numParameters, numParameters, numFreq, nv);
F = nan(numParameters, numParameters, nv);

% Create a command-window progress bar.
if opt.progress
    progress = ProgressBar('[IrisToolbox] @Model/fisher Progress');
end


for v = 1 : nv    
    % Fetch the i-th parameterisation.
    m = getVariant(this, v);
    
    % Minimum necessary state space.
    [T0, R0, Z0, H0, Omg0, nUnit0] = getSspace( );
    
    % SGF and inverse SGF at p0.
    [G, Gi] = computeSgfy(T0, R0, Z0, H0, Omg0, nUnit0, freq, opt);
    
    % Compute derivatives of SGF and steady state
    % wrt the selected parameters.
    dG = nan(ny, ny, numFreq, numParameters);
    if ~opt.Deviation
        dy = zeros(ny, numParameters);
    end
    % Determine differentiation step.
    p0 = nan(1, numParameters);
    p0(~inxNaPosValues) = m.Variant.Values(:, posValues(~inxNaPosValues), :);
    p0(~inxNaPosStdCorr) = m.Variant.StdCorr(:, posStdCorr(~inxNaPosStdCorr), :);
    step = max([abs(p0);ones(1, numParameters)], [ ], 1)*EPSILON;
    
    for i = 1 : numParameters
        pp = p0;
        pm = p0;
        pp(i) = pp(i) + step(i);
        pm(i) = pm(i) - step(i);
        twoSteps = pp(i) - pm(i);

        isSteady = ~opt.Deviation && ~isnan(posValues(i));
        
        % Steady state, state space and SGF at p0(i) + step(i).
        m = update(m, pp, 1);
        if isSteady
            yp = getSteady( );
        end
        [Tp, Rp, Zp, Hp, Omgp, nUnitp] = getSspace( );
        Gp = computeSgfy(Tp, Rp, Zp, Hp, Omgp, nUnitp, freq, opt);
        
        % Steady state, state space and SGF at p0(i) - step(i).
        m = update(m, pm, 1);
        if isSteady
            ym = getSteady( );
        end
        [Tm, Rm, Zm, Hm, Omgm, nUnitm] = getSspace( );
        Gm = computeSgfy(Tm, Rm, Zm, Hm, Omgm, nUnitm, freq, opt);
        
        % Differentiate SGF and steady state.
        dG(:, :, :, i) = (Gp - Gm) / twoSteps;
        if isSteady
            dy(:, i) = real(yp(:) - ym(:)) / twoSteps;
        end
        
        % Reset model parameters to `p0`.
        m.Variant.Values(:, posValues(~inxNaPosValues), :) = p0(1, ~inxNaPosValues);
        m.Variant.StdCorr(:, posStdCorr(~inxNaPosStdCorr), :) = p0(1, ~inxNaPosStdCorr);
        
        % Update the progress bar.
        if opt.progress
            update(progress, ((v-1)*numParameters+i)/(nv*numParameters));
        end
    end
    
    % Compute Fisher information matrix.
    % Steady-state-independent part.
    for i = 1 : numParameters
        for j = i : numParameters
            fi = zeros(1, numFreq);
            for k = 1 : numFreq
                fi(k) = trace( real(Gi(:, :, k)*dG(:, :, k, i)*Gi(:, :, k)*dG(:, :, k, j)) );
            end
            if ~opt.Deviation
                % Add steady-state effect to zero frequency.
                % We don't divide the effect by 2*pi because
                % we skip dividing G by 2*pi, too.
                A = dy(:, i)*dy(:, j)';
                fi(1) = fi(1) + numPeriods*trace(Gi(:, :, 1)*(A + A'));
            end
            FF(i, j, :, v) = fi;
            FF(j, i, :, v) = fi;
            f = delta*fi';
            F(i, j, v) = f;
            F(j, i, v) = f;
        end
    end

    if opt.percent
        P0 = diag(p0);
        F(:, :, v) = P0*F(:, :, v)*P0;
    end
    
end
% End of main loop.

FF = FF / 2;
F = F / 2;

% Clean up even though the model object is not returned
this.Update = this.EMPTY_UPDATE;

return


    function [T, R, Z, H, Omg, numUnitRoots] = getSspace( )
        [T, R, ~, Z, H, ~, ~, Omg] = getSolutionMatrices(m, 1);
        T = T(nf+1:end, :);
        Z = Z(~inxToExclude, :);
        R = R(nf+1:end, 1:ne);
        H = H(~inxToExclude, 1:ne);
        numUnitRoots = getNumOfUnitRoots(m.Variant);
    end 

    
    function y = getSteady( )
        % Get steady-state levels for measurement variables.
        y = m.Variant.Values(:, ixy, :);
        y = real(y);
        % Adjust for excluded measurement variables.
        y(inxToExclude) = [ ];
        % Take log of log variables; `ixYLog` has been already adjusted
        % for excluded measurement variables.
        y(ixYLog) = log(y(ixYLog));
    end 
end 


function [G, Gi] = computeSgfy(T, R, Z, H, Omg, numUnitRoots, freq, opt)
    % Spectrum generating function and its inverse.
    % Computationally optimised for observables.
    [ny, nb] = size(Z);
    numFreq = length(freq(:));
    Sgm1 = R*Omg*R.';
    Sgm2 = H*Omg*H.';
    G = nan(ny, ny, numFreq);
    for i = 1 : numFreq
        iFreq = freq(i);
        if iFreq==0 && numUnitRoots>0
            % Exclude the unit-root part of the transition matrix, and compute SGF only
            % for the stable part. Stationary variables are unaffected.
            Z0 = Z(:, numUnitRoots+1:end);
            T0 = T(numUnitRoots+1:end, numUnitRoots+1:end);
            R0 = R(numUnitRoots+1:end, :);
            X = Z0 / (eye(nb-numUnitRoots) - T0);
            G(:, :, i) = trimSymmetric(X*(R0*Omg*R0.')*X' + Sgm2);
        else
            X = Z/(eye(nb) - T*exp(-1i*iFreq));
            G(:, :, i) = trimSymmetric(X*Sgm1*X' + Sgm2);
        end
    end
    % Do not divide G by 2*pi.
    % First, this cancels out in Gi*dG*Gi*dG
    % and second, we do not divide the steady-state effect
    % by 2*pi either.
    if nargout>1
        Gi = nan(ny, ny, numFreq);
        if opt.chksgf
            for i = 1 : numFreq
                Gi(:, :, i) = computePseudoInverse(G(:, :, i), opt.tolerance);
            end
        else
            for i = 1 : numFreq
                Gi(:, :, i) = inv(G(:, :, i));
            end
        end
    end
end 


function x = trimSymmetric(x)
    % Minimise numerical inaccuracy between upper and lower parts
    % of symmetric matrices.
    indexDiagonal = logical(eye(size(x)));
    x = (x + x')/2;
    x(indexDiagonal) = real(x(indexDiagonal));
end 


function X = computePseudoInverse(A, Tol)
    c = class(A);
    if isempty(A)
        X = zeros(size(A'), c);
        return
    end
    sizeA = size(A);
    s = svd(A);
    r = sum(s/s(1)>Tol);
    if r==0
        X = zeros(size(A'), c);
    elseif r==sizeA(1)
        X = inv(A);
    else
        [U, ~, V] = svd(A, 0);
        S = diag(1./s(1:r));
        X = V(:, 1:r)*S*U(:, 1:r)';
    end
end
