function [YY, count] = ffrf3(model, systemProperty, variant)
% ffrf3  Frequence response function for general state space
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

[T, R, ~, Z, H, ~, U] = systemProperty.FirstOrderTriangular{:};
Omega = systemProperty.CovShocks;
numOfUnitRoots = systemProperty.NumUnitRoots;
freq = systemProperty.CallerData.Frequencies;
inxToInclude = systemProperty.CallerData.IndexToInclude;
tolerance = systemProperty.CallerData.Tolerance;
maxIter = systemProperty.CallerData.MaxIter;

%{
else
    [T, R, ~, Z, H, ~, U, Omega, numOfUnitRoots, freq, inxToInclude, tolerance, maxIter] = ...
end 
%}

ny = size(Z, 1);
[nx, nb] = size(T);
nf = nx - nb;

%--------------------------------------------------------------------------

Z1 = Z(inxToInclude, :);
H1 = H(inxToInclude, :);
ny1 = nnz(inxToInclude);

numOfFreq = numel(freq);
YY = complex(nan(nx, ny, numOfFreq), nan(nx, ny, numOfFreq));

% Solution not available, return immediately
if any(isnan(T(:)))
    if systemProperty.NumOfOutputs>=1
        systemProperty.Outputs{1} = YY;
    end
    return
end

count = 0;

% Index of zero frequencies (allow for multiple zeros in the vector).
inxOfZeroFreq = freq==0;
inxOfZeroFreq = inxOfZeroFreq(:);
numOfZeroFreq = nnz(inxOfZeroFreq);
numOfNonzeroFreq = nnz(~inxOfZeroFreq);

% Non-zero frquencies. Evaluate `xsf( )` and compute regressions.
if numOfNonzeroFreq>0
   nonzeroFreq( ); 
end

% We must do zero frequency last, becuase the input state space matrices
% are modified within zeroFreq( ).
if numOfZeroFreq>0
    zeroFreq( );
end

if systemProperty.NumOfOutputs>=1
    systemProperty.Outputs{1} = YY;
end

return


    function nonzeroFreq( )
        S = freqdom.xsf(T, R, [ ], Z1, H1, [ ], U, Omega, numOfUnitRoots, ...
            freq(~inxOfZeroFreq), [ ], [ ]);
        Yn = zeros(nx, ny1, numOfNonzeroFreq);
        for i = 1 : numOfNonzeroFreq
            S11 = S(1:ny1, 1:ny1, i);
            S12 = S(1:ny1, ny1+1:end, i);
            Yn(:, :, i) = S12' / S11;
        end
        YY(:, inxToInclude, ~inxOfZeroFreq) = Yn;
    end 


    function zeroFreq( )
        % dozerofreq  Compute FFRF for zero frequency by deriving a polynomial
        % representation of steady-state Kalman filter.
        Tf = T(1:nf, :);
        Rf = R(1:nf, :);
        T = T(nf+1:end, :);
        R = R(nf+1:end, :);
        Sy = H1*Omega*H1.';
        ROmg = R*Omega;
        Sa = ROmg*R';
        
        % Compute steady-state Kalman filter. Because the covariance matrix for the
        % measurement shocks can be singular (or absent at all) we cannot, in
        % general, use the doubling algorithm, and must iterate on the Riccati
        % equation.
        P = Sa;
        d = Inf;
        K = Inf;
        L = Inf;
        Z1t = Z1.';
        while d>tolerance && count<=maxIter
            K0 = K;
            PZ1t = P*Z1t;
            F = Z1*PZ1t + Sy;
            K = T*(PZ1t/F);
            L = T - K*Z1;
            P = T*P*L' + Sa;
            P = (P+P')/2;
            d = max(abs(K(:)-K0(:)));
            count = count + 1;
        end
        
        % Find infinite double-sided polynomial filters
        %     a(t) = Fa(q) y(t), 
        %     xf(t) = Ff(q) y(t), 
        % where q is the lag operator, and evaluate them for each frequency.
        
        Z1tFi = Z1.' / F;
        T_KZ1 = T - K*Z1;
        RfROmgt = Rf*ROmg';
        Ib = eye(nb);
        Iy = eye(ny1);
        Lt = L';
        Ff = zeros(nf, ny1);
        
        J = pinv(Ib - T_KZ1) * K;
        A = pinv(Ib - Lt) * (Z1tFi * (Iy - Z1*J));
        
        % FFRF(0) for alpha vector.
        Fa = J + P*A;
        if nf > 0
            % FFRF(0) for forward-looking variables.
            Ff = Tf*Fa + RfROmgt*A;
        end
        if ~isempty(U)
            % Transform the `alpha` vector back to the `x` vector.
            Y0 = [Ff;U*Fa];
        else
            Y0 = [Ff;Fa];
        end
        YY(:, inxToInclude, inxOfZeroFreq) = Y0(:, :, ones(1, numOfZeroFreq));
    end 
end%

