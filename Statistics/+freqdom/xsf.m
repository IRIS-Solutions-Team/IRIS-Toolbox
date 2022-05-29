function S = xsf(T, R, ~, Z, H, ~, U, Omega, numUnitRoots, freq, filter, applyFilterTo)
% xsf  Power spectrum generating function for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    filter; %#ok<*VUNUS>
catch %#ok<*CTCH>
    filter = double.empty(1, 0);
end

try
    applyFilterTo;
catch
    applyFilterTo = logical.empty(1, 0);
end

%--------------------------------------------------------------------------

isFilter = ~isempty(filter) && ~isempty(applyFilterTo) && any(applyFilterTo);

realSmall = getrealsmall( );
ny = size(Z, 1);
[nx, nb] = size(T);
nf = nx - nb;
ne = size(R, 2);

Tf = T(1:nf, :);
Ta = T(nf+1:end, :);
Rf = R(1:nf, 1:ne);
Ra = R(nf+1:end, :);
% Ta11 is an I matrix in difference-stationary models, but not an I matrix
% in I(2) and higher models.
Ta11 = T(nf+(1:numUnitRoots), 1:numUnitRoots);
Ta12 = T(nf+1:nf+numUnitRoots, numUnitRoots+1:end);
Ta22 = T(nf+numUnitRoots+1:end, numUnitRoots+1:end);
SigmaAA = Ra*Omega*transpose(Ra);
SigmaFF = Rf*Omega*transpose(Rf);
SigmaFA = Rf*Omega*transpose(Ra);
if ny>0
    SigmaYY = H*Omega*transpose(H);
end

numFreq = numel(freq);
S = zeros(ny+nf+nb, ny+nf+nb, numFreq);
ithS = zeros(ny+nf+nb, ny+nf+nb);

status = warning( );
warning('off'); 
for i = 1 : numFreq
    ithFreq = freq(i);
    if isFilter && filter(i)==0 && all(applyFilterTo) && ithFreq~=0
        continue
    end
    ee = exp(-1i*ithFreq);
    % F = eye(nf+nb) -  [zeros(nf+nb, nf), T]*exp(-1i*lambda);
    % xxx = F \ SigmaX / ctranspose(F);
    ithS(ny+1:end, ny+1:end) = inverse( );
    if ny>0
        ithS(1:ny, 1:ny) = Z*ithS(ny+nf+1:end, ny+nf+1:end)*transpose(Z) + SigmaYY;
        ithS(1:ny, ny+1:end) = Z*ithS(ny+nf+1:end, ny+1:end);
        ithS(ny+1:end, 1:ny) = ithS(ny+1:end, ny+nf+1:end)*transpose(Z);
    end
    if ithFreq==0
        % Diffuse y.
        if ny>0
            yInx = find(any(abs(Z(:, 1:numUnitRoots))>realSmall, 2));
            ithS(yInx, :) = Inf;
            ithS(:, yInx) = Inf;
        end
        % Diffuse xf.
        xfindex = find(any(abs(Tf(:, 1:numUnitRoots))>realSmall, 2));
        ithS(ny+xfindex, :) = Inf;
        ithS(:, ny+xfindex) = Inf;
    end
    if ~isempty(U)
        ithS(ny+nf+1:end, :) = U*ithS(ny+nf+1:end, :);
        ithS(:, ny+nf+1:end) = ithS(:, ny+nf+1:end)*U.';
        if ithFreq==0
            % Diffuse xb.
            xbindex = find(any(abs(U(:, 1:numUnitRoots))>realSmall, 2));
            ithS(ny+nf+xbindex, :) = Inf;
            ithS(:, ny+nf+xbindex) = Inf;
        end
    end
    if isFilter
        ithS(applyFilterTo, :) = filter(i)*ithS(applyFilterTo, :);
        ithS(:, applyFilterTo) = ithS(:, applyFilterTo)*conj(filter(i));
    end
    S(:, :, i) = ithS;
end
warning(status);

% Skip dividing S by 2*pi.

if ~isFilter
    for i = 1 : size(S, 1)
        S(i, i, :) = real(S(i, i, :));
    end
end

return


    function [Sxx, Saa] = inverse( )
        A = Tf*ee;
        %
        % B = inv(eye(nb) - Ta*ee) = inv([A11, A12;0, A22]) where
        %
        % * A11 = eye(numUnitRoots) - Ta11*ee (Ta11 is eye(numUnitRoots) only in
        % diff-stationary models).
        %
        % * A12 = -Ta12*ee.
        %
        % * A21 is zeros.
        %
        % * A22 = eye(nb-numUnitRoots) - Ta22*ee.
        %
        if ithFreq==0
            % Zero frequency; non-stationary variables not defined here
            B11 = zeros(numUnitRoots);
            B12 = zeros(numUnitRoots, nb-numUnitRoots);
            B22 = inv(eye(nb-numUnitRoots) - Ta22*ee);
            B = [B11, B12;zeros(nb-numUnitRoots, numUnitRoots), B22];
        else
            % Non-zero frequencies
            % B11 = inv(eye(numUnitRoots) - Ta11*ee);
            % B12 = (eye(numUnitRoots)-Ta11*ee) \ Ta12*B22*ee;
            % B22 = inv(eye(nb-numUnitRoots) - Ta22*ee);
            B = inv(eye(nb) - Ta*ee);
        end
        Saa = B*SigmaAA*ctranspose(B);
        Sfa = SigmaFA*ctranspose(B) + A*Saa;
        X = A*B*transpose(SigmaFA);
        Sff = SigmaFF + X + ctranspose(X) + Tf*Saa*transpose(Tf);
        Sxx = [Sff, Sfa; ctranspose(Sfa), Saa];
    end 
end
