function [M, Mxb, N, Nxb] = swapForecast(this, variantRequested, indexOfExogenized, indexOfEndogenized, last)
% myforecastswap  Model solution matrices with exogenized variables and endogenized shocks swapped
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

[ny, ~, nb, nf, ne] = sizeSolution(this.Vector);

% Current-dated variables in the original state vector.
ixXCurr = imag(this.Vector.Solution{2})==0;
nXCurr = sum(ixXCurr);
ixXfCurr = ixXCurr(1:nf);
ixXbCurr = ixXCurr(nf+1:end);

% Constant.
Mxc = zeros(nXCurr*last, 1);
Myc = zeros(ny*last, 1);
mbc = zeros(nb, 1);
% Multipliers on initial condition.
Mx0 = zeros(nXCurr*last, nb);
My0 = zeros(ny*last, nb);
mb0 = eye(nb);
% Multipliers on unexpected shocks.
Mxu = zeros(nXCurr*last, ne*last);
Myu = zeros(ny*last, ne*last);
mbu = zeros(nb, ne*last);
% Multipliers on expected shocks.
Mxe = zeros(nXCurr*last, ne*last);
Mye = zeros(ny*last, ne*last);
mbe = zeros(nb, ne*last);

% System matrices.
keepExpansion = true;
triangular = false;
[T, R, K, Z, H, D] = getSolutionMatrices( this, ...
                                     variantRequested, ...
                                     keepExpansion, ...
                                     triangular );
Tf = T(1:nf, :);
Tb = T(nf+1:end, :);
Ru = R(:, 1:ne);
Re = R(:, 1:ne*last);
Kf = K(1:nf, :);
Kb = K(nf+1:end, :);

for t = 1 : last
    % Constant.
    mfc = Tf*mbc + Kf;
    mbc = Tb*mbc + Kb;
    Mxc((t-1)*nXCurr+(1:nXCurr), 1) = [ mfc(ixXfCurr, :)
                                        mbc(ixXbCurr, :) ];
    Myc((t-1)*ny+(1:ny), 1) = Z*mbc + D;
    % Initial condition.
    mf0 = Tf*mb0;
    mb0 = Tb*mb0;
    Mx0((t-1)*nXCurr+(1:nXCurr), :) = [ mf0(ixXfCurr, :)
                                        mb0(ixXbCurr, :) ];
    My0((t-1)*ny+(1:ny), :) = Z*mb0;
    % Unexpected.
    mfu = Tf*mbu;
    mbu = Tb*mbu;
    mfu(:, (t-1)*ne+(1:ne)) = mfu(:, (t-1)*ne+(1:ne)) + Ru(1:nf, :);
    mbu(:, (t-1)*ne+(1:ne)) = mbu(:, (t-1)*ne+(1:ne)) + Ru(nf+1:end, :);
    myu = Z*mbu;
    myu(:, (t-1)*ne+(1:ne)) = myu(:, (t-1)*ne+(1:ne)) + H;
    Mxu((t-1)*nXCurr+(1:nXCurr), :) = [ mfu(ixXfCurr, :)
                                        mbu(ixXbCurr, :) ];
    Myu((t-1)*ny+(1:ny), :) = myu;
    % Expected.
    mfe = Tf*mbe;
    mbe = Tb*mbe;
    mfe(:, (t-1)*ne+1:end) = mfe(:, (t-1)*ne+1:end) + Re(1:nf, :);
    mbe(:, (t-1)*ne+1:end) = mbe(:, (t-1)*ne+1:end) + Re(nf+1:end, :);
    Re(:, end-ne+1:end) = [ ];
    mye = Z*mbe;
    mye(:, (t-1)*ne+(1:ne)) = mye(:, (t-1)*ne+(1:ne)) + H;
    Mxe((t-1)*nXCurr+(1:nXCurr), :) = [ mfe(ixXfCurr, :)
                                        mbe(ixXbCurr, :) ];
    Mye((t-1)*ny+(1:ny), :) = mye;
end

% Original system I*[Xb_last; Y; X] = M*[Const; Xb_0; U; E]
% Add the Xb_last vector so that it is easy to retrieve the
% initial condition for simulating the model after t=last.
M = [ mbc, mb0, mbu, mbe
      Myc, My0, Myu, Mye
      Mxc, Mx0, Mxu, Mxe ];
indexOfExogenized = [false(1, nb), indexOfExogenized];

% When computing MSE matrices, we treat expected shocks as unexpected.
if nargout>2
    N = [ mbc, mb0, mbu, mbu
          Myc, My0, Myu, Myu
          Mxc, Mx0, Mxu, Mxu ];
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
    M = [ M11-M12_iM22*M21, M12_iM22
          -iM22*M21, iM22 ];
    
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
        N = [ N11-N12_iN22*N21, N12_iN22
              -iN22*N21, iN22 ];
    end
end

Mxb = M(1:nb, :);
M = M(nb+1:end, :);
if nargout>2
    Nxb = N(1:nb, :);
    N = N(nb+1:end, :);
end

end%
