function [Y,Count] = ffrf3(T,R,~,Z,H,~,U,Omg,NUnit,Freq,Incl,Tol,MaxIter)
% ffrf3  [Not a public function] Frequence response function for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;

if isempty(Tol)
    Tol = 1e-7;
end

if isempty(MaxIter)
    MaxIter = 500;
end

if isequal(Incl,Inf)
    Incl = true(ny,1);
end

%--------------------------------------------------------------------------

Z1 = Z(Incl,:);
H1 = H(Incl,:);
ny1 = sum(Incl);

Freq = Freq(:).';
nFreq = length(Freq);
Y = nan(nx,ny,nFreq);
Count = 0;

% Index of zero frequencies (allow for multiple zeros in the vector).
zeroFreqInx = Freq == 0;

% Non-zero frquencies. Evaluate `xsf( )` and compute regressions.
if any(~zeroFreqInx)
   doNonzeroFreq( ); 
end

% We must do zero frequency last, becuase the input state space matrices
% are modified within `dozerofreq( )`.
if any(zeroFreqInx)
    doZeroFreq( );
end


% Nested functions...


%**************************************************************************

    
    function doNonzeroFreq( )
        S = freqdom.xsf(T,R,[ ],Z1,H1,[ ],U,Omg,NUnit, ...
            Freq(~zeroFreqInx),[ ],[ ]);
        nNonzero = sum(~zeroFreqInx);
        Yn = zeros(nx,ny1,nNonzero);
        for i = 1 : nNonzero
            S11 = S(1:ny1,1:ny1,i);
            S12 = S(1:ny1,ny1+1:end,i);
            Yn(:,:,i) = S12' / S11;
        end
        Y(:,Incl,~zeroFreqInx) = Yn;
    end % doNonzeroFreq( )


%**************************************************************************
    
    
    function doZeroFreq( )
        % dozerofreq  Compute FFRF for zero frequency by deriving a polynomial
        % representation of steady-state Kalman filter.
        Tf = T(1:nf,:);
        Rf = R(1:nf,:);
        T = T(nf+1:end,:);
        R = R(nf+1:end,:);
        Sy = H1*Omg*H1.';
        ROmg = R*Omg;
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
        while d > Tol && Count <= MaxIter
            K0 = K;
            PZ1t = P*Z1t;
            F = Z1*PZ1t + Sy;
            K = T*(PZ1t/F);
            L = T - K*Z1;
            P = T*P*L' + Sa;
            P = (P+P')/2;
            d = max(abs(K(:)-K0(:)));
            Count = Count + 1;
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
        Ff = zeros(nf,ny1);
        
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
        nZero = sum(zeroFreqInx);
        Y(:,Incl,zeroFreqInx) = Y0(:,:,ones(1,nZero));
    end % doZeroFreq( )


end