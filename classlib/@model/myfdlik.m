function [obj, regOutp] = myfdlik(this, inp, ~, likOpt)
% myfdlik  Approximate likelihood function in frequency domain.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% TODO: Allow for non-stationary measurement variables.

STEADY_TOLERANCE = this.Tolerance.Steady;
TYPE = @int8;

%--------------------------------------------------------------------------

s = struct( );
s.noutoflik = length(likOpt.outoflik);
s.isObjOnly = nargout==1;

nAlt = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ny = sum(ixy);
ne = sum(ixe);

% Number of original periods.
[~, nPer, nData] = size(inp);
freq = 2*pi*(0 : nPer-1)/nPer;

% Number of fundemantal frequencies.
N = 1 + floor(nPer/2);
freq = freq(1:N);

% Band of frequencies.
frqLo = 2*pi/max(likOpt.band);
frqHi = 2*pi/min(likOpt.band);
ixFrq = freq>=frqLo & freq<=frqHi;

% Drop zero frequency unless requested.
if ~likOpt.zero
    ixFrq(freq==0) = false;
end
ixFrq = find(ixFrq);
nFrq = length(ixFrq);

% Kronecker delta.
kr = ones(1, N);
if mod(nPer, 2)==0
    kr(2:end-1) = 2;
else
    kr(2:end) = 2;
end

nLoop = max(nAlt, nData);

% Pre-allocate output data.
nObj = 1;
if likOpt.objdecomp
    nObj = nFrq + 1;
end
obj = nan(nObj, nLoop);

if ~s.isObjOnly
    regOutp = struct( );
    regOutp.V = nan(1, nLoop, likOpt.precision);
    regOutp.Delta = nan(s.noutoflik, nLoop, likOpt.precision);
    regOutp.PDelta = nan(s.noutoflik, s.noutoflik, nLoop, likOpt.precision);
end

for iLoop = 1 : nLoop
    % Next data
    %-----------
    % Measurement variables.
    y = inp(1:ny, :, min(iLoop, end));
    % Exogenous variables in dtrend equations.
    g = inp(ny+1:end, :, min(iLoop, end));
    excl = likOpt.exclude(:) | any(isnan(y), 2);
    nYIncl = sum(~excl);
    diagInx = logical(eye(nYIncl));
    
    if iLoop<=nAlt
        
        [T, R, K, Z, H, D, U, Omg] = mysspace(this, iLoop, false); %#ok<ASGLU>
        [nx, nb] = size(T);
        nf = nx - nb;
        nUnit = sum(this.Variant{iLoop}.Stability==TYPE(1));
        % Z(1:nunit, :) assumed to be zeros.
        if any(any( abs(Z(:, 1:nUnit))>STEADY_TOLERANCE ))
            utils.error('model:myfdlik', ...
                ['Cannot evalutate likelihood in frequency domain ', ...
                'with non-stationary measurement variables.']);
        end
        T = T(nf+nUnit+1:end, nUnit+1:end);
        R = R(nf+nUnit+1:end, 1:ne);
        Z = Z(~excl, nUnit+1:end);
        H = H(~excl, :);
        Sa = R*Omg*transpose(R);
        Sy = H(~excl, :)*Omg*H(~excl, :).';
        
        % Fourier transform of steady state.
        isSstate = false;
        if ~likOpt.deviation
            id = find(ixy);
            isDelog = false;
            S = createTrendArray(this, iLoop, isDelog, id, 1:nPer);
            isSstate = any(S(:) ~= 0);
            if isSstate
                S = S.';
                S = fft(S);
                S = S.';
            end
        end
        
    end
        
    % Fourier transform of deterministic trends.
    isDtrends = false;
    nOutOfLik = 0;
    if likOpt.dtrends
        [D, M] = evalDtrends(this, likOpt.outoflik, g, iLoop);
        isDtrends = any(D(:) ~= 0);
        if isDtrends
            D = fft(D.').';
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
    if ~likOpt.deviation && isSstate
        y = y - S;
    end
    
    % Subtract deterministic trends from observations.
    if likOpt.dtrends && isDtrends
        y = y - D;
    end
    
    % Remove measurement variables excluded from likelihood by the user, or
    % those that have within-sample NaNs.
    y = y(~excl, :);
    y = y / sqrt(nPer);
    
    M = M(~excl, :, :);
    M = M / sqrt(nPer);
    
    L0 = zeros(1, nFrq+1);
    L1 = zeros(1, nFrq+1);
    L2 = zeros(nOutOfLik, nOutOfLik, nFrq+1);
    L3 = zeros(nOutOfLik, nFrq+1);
    nObs = zeros(1, nFrq+1);
    
    pos = 0;
    for i = ixFrq
        pos = pos + 1;
        iFreq = freq(i);
        iDelta = kr(i);
        iY = y(:, i);
        oneFrequency( );
    end
    
    [obj(:, iLoop), V, Delta, PDelta] = kalman.oolik(L0, L1, L2, L3, nObs, likOpt);
    
    if s.isObjOnly
        continue
    end
    
    regOutp.V(1, iLoop) = V;
    regOutp.Delta(:, iLoop) = Delta;
    regOutp.PDelta(:, :, iLoop) = PDelta;    
end

return
    
    
    
    
    function oneFrequency( )
        nObs(1, 1+pos) = iDelta*nYIncl;
        ZiW = Z / ((eye(size(T)) - T*exp(-1i*iFreq)));
        G = ZiW*Sa*ZiW' + Sy;
        G(diagInx) = real(G(diagInx));
        L0(1, 1+pos) = iDelta*real(log(det(G)));
        L1(1, 1+pos) = iDelta*real((y(:, i)'/G)*iY);
        if isOutOfLik
            MtGi = M(:, :, i)'/G;
            L2(:, :, 1+pos) = iDelta*real(MtGi*M(:, :, i));
            L3(:, 1+pos) = iDelta*real(MtGi*iY);
        end
    end
end
