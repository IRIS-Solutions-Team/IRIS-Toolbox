function [M, Ma, N, Na] = myforecastswap(this, variantRequested, indexOfExogenized, indexOfEndogenized, last)
% myforecastswap  Model solution matrices with exogenized variables and endogenized shocks swapped.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[ny, ~, nb, nf, ne] = sizeSolution(this.Vector);

% Current-dated variables in the original state vector.
ixXCurr = imag(this.Vector.Solution{2}) == 0;
nXCurr = sum(ixXCurr);
ixXfCurr = ixXCurr(1:nf);
ixXbCurr = ixXCurr(nf+1:end);

% Constant.
Mxc = zeros(nXCurr*last, 1);
Myc = zeros(ny*last, 1);
mac = zeros(nb, 1);
% Multipliers on initial condition.
Mx0 = zeros(nXCurr*last, nb);
My0 = zeros(ny*last, nb);
ma0 = eye(nb);
% Multipliers on unexpected shocks.
Mxu = zeros(nXCurr*last, ne*last);
Myu = zeros(ny*last, ne*last);
mau = zeros(nb, ne*last);
% Multipliers on expected shocks.
Mxe = zeros(nXCurr*last, ne*last);
Mye = zeros(ny*last, ne*last);
mae = zeros(nb, ne*last);

% System matrices.
[T, R, K, Z, H, D, U] = getSolutionMatrices(this, variantRequested);
Tf = T(1:nf, :);
Ta = T(nf+1:end, :);
Ru = R(:, 1:ne);
Re = R(:, 1:ne*last);
Kf = K(1:nf, :);
Ka = K(nf+1:end, :);
UCurr = U(ixXbCurr, :);

for t = 1 : last
    % Constant.
    mfc = Tf*mac + Kf;
    mac = Ta*mac + Ka;
    Mxc((t-1)*nXCurr+(1:nXCurr), 1) = [mfc(ixXfCurr, :);UCurr*mac];
    Myc((t-1)*ny+(1:ny), 1) = Z*mac + D;
    % Initial condition.
    mf0 = Tf*ma0;
    ma0 = Ta*ma0;
    Mx0((t-1)*nXCurr+(1:nXCurr), :) = [mf0(ixXfCurr, :);UCurr*ma0];
    My0((t-1)*ny+(1:ny), :) = Z*ma0;
    % Unexpected.
    mfu = Tf*mau;
    mau = Ta*mau;
    mfu(:, (t-1)*ne+(1:ne)) = mfu(:, (t-1)*ne+(1:ne)) + Ru(1:nf, :);
    mau(:, (t-1)*ne+(1:ne)) = mau(:, (t-1)*ne+(1:ne)) + Ru(nf+1:end, :);
    myu = Z*mau;
    myu(:, (t-1)*ne+(1:ne)) = myu(:, (t-1)*ne+(1:ne)) + H;
    Mxu((t-1)*nXCurr+(1:nXCurr), :) = [mfu(ixXfCurr, :);UCurr*mau];
    Myu((t-1)*ny+(1:ny), :) = myu;
    % Expected.
    mfe = Tf*mae;
    mae = Ta*mae;
    mfe(:, (t-1)*ne+1:end) = mfe(:, (t-1)*ne+1:end) + Re(1:nf, :);
    mae(:, (t-1)*ne+1:end) = mae(:, (t-1)*ne+1:end) + Re(nf+1:end, :);
    Re(:, end-ne+1:end) = [ ];
    mye = Z*mae;
    mye(:, (t-1)*ne+(1:ne)) = mye(:, (t-1)*ne+(1:ne)) + H;
    Mxe((t-1)*nXCurr+(1:nXCurr), :) = [mfe(ixXfCurr, :);UCurr*mae];
    Mye((t-1)*ny+(1:ny), :) = mye;
end

% Original system I*[AlpLast;Y;X] = M*[Const;Alp0;U;E].
% Add the alpha vector at t=last so that it is easy to retrieve the
% initial condition for simulating the model after t=last.
M = [ ...
    mac, ma0, mau, mae ; ...
    Myc, My0, Myu, Mye ; ...
    Mxc, Mx0, Mxu, Mxe ; ...
    ];
indexOfExogenized = [false(1, nb), indexOfExogenized];

% When computing MSE matrices, we treat expected shocks as unexpected.
if nargout > 2
    N = [ ...
        mac, ma0, mau, mau ; ...
        Myc, My0, Myu, Myu ; ...
        Mxc, Mx0, Mxu, Mxu ; ...
        ];
end

if any(indexOfExogenized) || any(indexOfEndogenized)
    % Swap the endogenised and exogenised columns in I and A matrices.
    % I = eye(size(M, 1));
    % I1 = I(:, ~Exi);
    % I2 = I(:, Exi);
    % M1 = M(:, ~Endi);
    % M2 = M(:, Endi);
    % M = [I1, -M2]\[M1, -I2];
    M11 = M(~indexOfExogenized, ~indexOfEndogenized);
    M12 = M(~indexOfExogenized, indexOfEndogenized);
    M21 = M(indexOfExogenized, ~indexOfEndogenized);
    M22 = M(indexOfExogenized, indexOfEndogenized);
    iM22 = inv(M22);
    M12_iM22 = M12*iM22; %#ok<MINV>
    M = [ ...
        M11-M12_iM22*M21, M12_iM22; ...
        -iM22*M21, iM22; ...
        ];
    
    if nargout>2
        % N1 = N(:, ~Endi);
        % N2 = N(:, Endi);
        % NN = [I1, -N2]\[N1, -I2];        
        N11 = N(~indexOfExogenized, ~indexOfEndogenized);
        N12 = N(~indexOfExogenized, indexOfEndogenized);
        N21 = N(indexOfExogenized, ~indexOfEndogenized);
        N22 = N(indexOfExogenized, indexOfEndogenized);
        iN22 = inv(N22);
        N12_iN22 = N12*iN22; %#ok<MINV>
        N = [ ...
            N11-N12_iN22*N21, N12_iN22; ...
            -iN22*N21, iN22; ...
            ];
    end
end

Ma = M(1:nb, :);
M = M(nb+1:end, :);
if nargout > 2
    Na = N(1:nb, :);
    N = N(nb+1:end, :);
end

end
