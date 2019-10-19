function [obj, regOutp] = freql(this, inp, ~, ~, likOpt)
% freql  Approximate likelihood function in frequency domain
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

% TODO: Allow for non-stationary measurement variables

STEADY_TOLERANCE = this.Tolerance.Steady;
TYPE = @int8;

%--------------------------------------------------------------------------

s = struct( );
s.NumOutOfLik = length(likOpt.OutOfLik);
s.isObjOnly = nargout==1;

nv = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ny = sum(ixy);
ne = sum(ixe);

% Number of original periods.
[~, numPeriods, nData] = size(inp);
freq = 2*pi*(0 : numPeriods-1)/numPeriods;

% Number of fundemantal frequencies.
N = 1 + floor(numPeriods/2);
freq = freq(1:N);

% Band of frequencies.
frqLo = 2*pi/max(likOpt.Band);
frqHi = 2*pi/min(likOpt.Band);
inxFreq = freq>=frqLo & freq<=frqHi;

% Drop zero frequency unless requested.
if ~likOpt.Zero
    inxFreq(freq==0) = false;
end
inxFreq = find(inxFreq);
numFreq = length(inxFreq);

% Kronecker delta.
kr = ones(1, N);
if mod(numPeriods, 2)==0
    kr(2:end-1) = 2;
else
    kr(2:end) = 2;
end

numRuns = max(nv, nData);

% Pre-allocate output data.
nObj = 1;
if likOpt.ObjFuncContributions
    nObj = numFreq + 1;
end
obj = nan(nObj, numRuns);

if ~s.isObjOnly
    regOutp = struct( );
    regOutp.V = nan(1, numRuns);
    regOutp.Delta = nan(s.NumOutOfLik, numRuns);
    regOutp.PDelta = nan(s.NumOutOfLik, s.NumOutOfLik);
end

for i = 1 : numRuns
    % __Next Data__
    % Measurement variables.
    y = inp(1:ny, :, min(i, end));
    % Exogenous variables in DTrend equations.
    g = inp(ny+1:end, :, min(i, end));
    inxToExclude = likOpt.InxToExclude(:) | any(isnan(y), 2);
    nYIncl = sum(~inxToExclude);
    inxOfDiag = logical(eye(nYIncl));
    
    if i<=nv
        [T, R, K, Z, H, W, U, Omg] = sspaceMatrices(this, i, false); %#ok<ASGLU>
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
        R = R(nf+numOfUnitRoots+1:end, 1:ne);
        Z = Z(~inxToExclude, numOfUnitRoots+1:end);
        H = H(~inxToExclude, :);
        Sa = R*Omg*transpose(R);
        Sy = H(~inxToExclude, :)*Omg*H(~inxToExclude, :).';
        
        % Fourier transform of steady state.
        isSstate = false;
        if ~likOpt.Deviation
            id = find(ixy);
            isDelog = false;
            S = createTrendArray(this, i, isDelog, id, 1:numPeriods);
            isSstate = any(S(:) ~= 0);
            if isSstate
                S = S.';
                S = fft(S);
                S = S.';
            end
        end
        
    end
        
    % Fourier transform of deterministic trends
    isTrendEquations = false;
    nOutOfLik = 0;
    if likOpt.DTrends
        [W, M] = evalTrendEquations(this, likOpt.OutOfLik, g, i);
        isTrendEquations = any(W(:)~=0);
        if isTrendEquations
            W = fft(W.').';
        end
        isOutOfLik = ~isempty(M) && any(M(:) ~= 0);
        if isOutOfLik
            M = permute(M, [3, 1, 2]);
            M = fft(M);
            M = ipermute(M, [3, 1, 2]);
        end
        nOutOfLik = size(M, 2);
    end
        
    % Subtract sstate trends from observations; note that fft(y-s)
    % equals fft(y) - fft(s).
    if ~likOpt.Deviation && isSstate
        y = y - S;
    end
    
    % Subtract deterministic trends from observations.
    if likOpt.DTrends && isTrendEquations
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
    L2 = zeros(nOutOfLik, nOutOfLik, numFreq+1);
    L3 = zeros(nOutOfLik, numFreq+1);
    numObs = zeros(1, numFreq+1);
    
    pos = 0;
    for j = inxFreq
        pos = pos + 1;
        ithFreq = freq(j);
        iDelta = kr(j);
        iY = y(:, j);
        hereOneFrequency( );
    end
    
    [obj(:, i), V, Delta, PDelta] = kalman.oolik(L0, L1, L2, L3, numObs, likOpt);
    
    if s.isObjOnly
        continue
    end
    
    regOutp.V(1, i) = V;
    regOutp.Delta(:, i) = Delta;
    regOutp.PDelta(:, :, i) = PDelta;    
end

return
    
    
    function hereOneFrequency( )
        numObs(1, 1+pos) = iDelta*nYIncl;
        ZiW = Z / ((eye(size(T)) - T*exp(-1i*ithFreq)));
        G = ZiW*Sa*ZiW' + Sy;
        G(inxOfDiag) = real(G(inxOfDiag));
        L0(1, 1+pos) = iDelta*real(log(det(G)));
        L1(1, 1+pos) = iDelta*real((y(:, j)'/G)*iY);
        if isOutOfLik
            MtGi = M(:, :, j)'/G;
            L2(:, :, 1+pos) = iDelta*real(MtGi*M(:, :, j));
            L3(:, 1+pos) = iDelta*real(MtGi*iY);
        end
    end%
end%
