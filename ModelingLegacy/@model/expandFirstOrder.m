function [R, Y] = expandFirstOrder(R0, Y0, expansion, k)
% expandFirstOrder  Reconstruct forward expansion up to t+k for one parameter variant
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

nv = size(R0, 3);
returnY = nargout>=2;

[Xa, Xf, Ru, J, Yu] = expansion{:};

ne = size(Ru, 2);
if returnY
    nh = size(Yu, 2);
else
    nh = 0;
end

if ne==0 && nh==0
    return
end

% Pre-allocate NaNs
R = [R0(:, 1:ne, :), nan(size(R0, 1), ne*k, nv)];
if returnY
    Y = [Y0(:, 1:nh, :), nan(size(Y0, 1), nh*k, nv)];
end

% Expansion matrices not available
if any(isnan(Xa(:))) || k==0
    return
end

%{
Jk = eye(size(J));
for i = k0+1 : k
    Ra = -Xa*Jk*Ru; % Jk stores J^(k-1).
    Ya = -Xa*Jk*Yu;
    Jk = Jk*J;
    Rf = Xf*Jk*Ru;
    Yf = Xf*Jk*Yu;
    R(:, i*ne+(1:ne)) = [Rf;Ra];
    Y(:, i*nh+(1:nh)) = [Yf;Ya];
end
%}

for v = 1 : nv
    %
    % Expected shocks in transition equations
    %
    vthJ = J(:, :, v);
    vthX = [ Xf(:, :, v)*vthJ; -Xa(:, :, v) ];
    vthRu = Ru(:, :, v);
    for i = 1 : k
        R(:, i*ne+(1:ne), v) = vthX*vthRu;
        vthRu = vthJ*vthRu;
    end

    %
    % Nonlinear effect in hash equations
    %
    if returnY
        vthYu = Yu(:, :, v);
        for i = 1 : k
            Y(:, i*nh+(1:nh), v) = vthX*vthYu;
            vthYu = vthJ*vthYu;
        end
    end
end

end%

