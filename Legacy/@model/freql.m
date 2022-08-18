function [obj, regOutp] = freql(this, argin)

% TODO: Non-stationary measurement variables

STEADY_TOLERANCE = this.Tolerance.Steady;
opt = argin.Options;

%--------------------------------------------------------------------------

s = struct( );
s.NumOutlik = numel(argin.Options.Outlik);
s.isObjOnly = nargout==1;

nv = countVariants(this);
inxY = this.Quantity.Type==1;
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;
numY = sum(inxY);
numE = sum(inxE);

% Number of original periods.
[~, numPeriods, numPages] = size(argin.InputData);
freq = 2*pi*(0 : numPeriods-1)/numPeriods;

% Number of fundemantal frequencies
N = 1 + floor(numPeriods/2);
freq = freq(1:N);

% Band of frequencies.
frqLo = 2*pi/max(argin.Options.Band);
frqHi = 2*pi/min(argin.Options.Band);
inxFreq = freq>=frqLo & freq<=frqHi;

% Drop zero frequency unless requested
if ~argin.Options.Zero
    inxFreq(freq==0) = false;
end
numFreq = nnz(inxFreq);

% Kronecker delta.
kr = ones(1, N);
if mod(numPeriods, 2)==0
    kr(2:end-1) = 2;
else
    kr(2:end) = 2;
end

numRuns = max(nv, numPages);

%
% Pre-allocate output data
%
numObjFuncs = 1;
if argin.Options.ReturnObjFuncContribs
    numObjFuncs = numFreq + 1;
end
obj = nan(numObjFuncs, numRuns);

if ~s.isObjOnly
    regOutp = struct( );
    regOutp.V = nan(1, numRuns);
    regOutp.Delta = nan(s.NumOutlik, numRuns);
    regOutp.PDelta = nan(s.NumOutlik, s.NumOutlik);
end

for i = 1 : numRuns
    %
    % Next measurement variables
    %
    y = argin.InputData(1:numY, :, min(i, end));

    %
    % Next exogenous variables in dtrend equations
    %
    g = argin.InputData(numY+1:end, :, min(i, end));

    inxToExclude = argin.Options.InxToExclude(:) | any(isnan(y), 2);
    nYIncl = sum(~inxToExclude);
    inxOfDiag = logical(eye(nYIncl));

    if i<=nv
        [T, R, K, Z, H, W, U, Omg] = getSolutionMatrices(this, i, false); %#ok<ASGLU>
        [nx, nb] = size(T);
        nf = nx - nb;
        numOfUnitRoots = getNumOfUnitRoots(this.Variant, i);
        % Z(1:nunit, :) assumed to be zeros.
        if any(any( abs(Z(:, 1:numOfUnitRoots))>STEADY_TOLERANCE ))
            THIS_ERROR = { 'Model:NonStationarityInFreqDomain'
                           [ 'Cannot evalutate likelihood in frequency domain ', ...
                             'with non-stationary measurement variables.' ] };
            throw( exception.Base(THIS_ERROR, 'error') );
        end
        T = T(nf+numOfUnitRoots+1:end, numOfUnitRoots+1:end);
        R = R(nf+numOfUnitRoots+1:end, 1:numE);
        Z = Z(~inxToExclude, numOfUnitRoots+1:end);
        H = H(~inxToExclude, :);
        Sa = R*Omg*transpose(R);
        Sy = H(~inxToExclude, :)*Omg*H(~inxToExclude, :).';

        % Fourier transform of steady state
        isSteady = false;
        if ~argin.Options.Deviation
            id = find(inxY);
            isDelog = false;
            S = createTrendArray(this, i, isDelog, id, 1:numPeriods);
            isSteady = any(S(:) ~= 0);
            if isSteady
                S = S.';
                S = fft(S);
                S = S.';
            end
        end

    end

    % Fourier transform of deterministic trends
    isTrendEquations = false;
    numOutlik = 0;
    if argin.Options.EvalTrends
        [W, M] = evalTrendEquations(this, argin.Options.Outlik, g, i);
        isTrendEquations = any(W(:)~=0);
        if isTrendEquations
            W = fft(W.').';
        end
        isPouts = ~isempty(M) && any(M(:) ~= 0);
        if isPouts
            M = permute(M, [3, 1, 2]);
            M = fft(M);
            M = ipermute(M, [3, 1, 2]);
        end
        numOutlik = size(M, 2);
    end

    % Subtract sstate trends from observations; note that fft(y-s)
    % equals fft(y) - fft(s).
    if ~argin.Options.Deviation && isSteady
        y = y - S;
    end

    % Subtract deterministic trends from observations.
    if argin.Options.EvalTrends && isTrendEquations
        y = y - W;
    end

    % Remove measurement variables inxToExcludeuded from likelihood by the user, or
    % those that have within-sample NaNs.
    y = y(~inxToExclude, :);
    y = y / sqrt(numPeriods);

    M = M(~inxToExclude, :, :);
    M = M / sqrt(numPeriods);

    L0 = zeros(1, numFreq+1);
    L1 = zeros(1, numFreq+1);
    L2 = zeros(numOutlik, numOutlik, numFreq+1);
    L3 = zeros(numOutlik, numFreq+1);
    numObs = zeros(1, numFreq+1);

    pos = 0;
    for j = reshape(find(inxFreq), 1, [ ])
        pos = pos + 1;
        freq__ = freq(j);
        delta__ = kr(j);
        y__ = y(:, j);
        hereOneFrequency( );
    end

    [obj(:, i), V, Delta, PDelta] = iris.mixin.Kalman.likelihood(L0, L1, L2, L3, numObs, opt);

    if s.isObjOnly
        continue
    end

    regOutp.V(1, i) = V;
    regOutp.Delta(:, i) = Delta;
    regOutp.PDelta(:, :, i) = PDelta;
end

return


    function hereOneFrequency( )
        numObs(1, 1+pos) = delta__*nYIncl;
        ZiW = Z / ((eye(size(T)) - T*exp(-1i*freq__)));
        G = ZiW*Sa*ZiW' + Sy;
        G(inxOfDiag) = real(G(inxOfDiag));
        L0(1, 1+pos) = delta__*real(log(det(G)));
        L1(1, 1+pos) = delta__*real((y(:, j)'/G)*y__);
        if isPouts
            MtGi = M(:, :, j)'/G;
            L2(:, :, 1+pos) = delta__*real(MtGi*M(:, :, j));
            L3(:, 1+pos) = delta__*real(MtGi*y__);
        end
    end%
end%
