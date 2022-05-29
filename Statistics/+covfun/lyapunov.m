function C = lyapunov(T,SGM,BETA,FIRSTROW)
% lyapunov  [Not a public function] Solve Lyapunov equation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%#ok<*TRYNC>
%#ok<*CTCH>
%#ok<*VUNUS>

% Discounted equation.
try 
    if BETA < 1
        T = sqrt(BETA)*T;
    end
end

% Process rows `FIRSTROW` to end only.
try
    FIRSTROW;
catch 
    FIRSTROW = 1;
end

%**************************************************************************

% Solve the following Lyapunov equation
%
%     C = beta*T*C*T' + Sigma,
%
% assuming `T` is quasi-triangular.

C = zeros(size(T));
i = size(T,1);
Tt = T.';
while i >= FIRSTROW
    if i == 1 || T(i,i-1) == 0
        % 1x1 block with a real eigenvalue.
        C(i,i+1:end) = C(i+1:end,i).';
        c = (SGM(i,1:i) + T(i,i)*C(i,i+1:end)*Tt(i+1:end,1:i) + ...
            T(i,i+1:end)*C(i+1:end,:)*Tt(:,1:i)) / (eye(i) - T(i,i)*Tt(1:i,1:i));
        C(i,1:i) = c;
        i = i - 1;
    else
        % 2x2 block corresponding to a pair of complex eigenvalues.
        C(i-1:i,i+1:end) = C(i+1:end,i-1:i).';
        X = T(i-1:i,i-1:i)*C(i-1:i,i+1:end)*Tt(i+1:end,1:i) + ...
            T(i-1:i,i+1:end)*C(i+1:end,:)*Tt(:,1:i) + SGM(i-1:i,1:i);
        % Solve
        %     c = T(i-1:i,i-1:i)*c*Tt(1:i,1:i) + X
        % Transpose the equation first
        %     c' = Tt'*c'*T' + X'
        % so that the below kronecker product becomes faster to evaluate,
        % then vectorize
        %     vec(c') = kron(T,Tt')*vec(c') + vec(X').
        Xt = X.';
        U = Tt(1:i,1:i).';
        k = [T(i-1,i-1)*U,T(i-1,i)*U;T(i,i-1)*U,T(i,i)*U];
        ct = (eye(2*i) - k) \ Xt(:);
        C(i-1:i,1:i) = reshape(ct,[i,2]).';
        i = i - 2;
    end
end

if FIRSTROW > 1
    C(1:FIRSTROW-1,FIRSTROW:end) = C(FIRSTROW:end,1:FIRSTROW-1).';
end

end
