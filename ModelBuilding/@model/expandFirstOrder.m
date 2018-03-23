function [R, Y] = expandFirstOrder(R, Y, expansion, k)
% expandFirstOrder  Expan first-order solution forward up to t+k for one parameter variant.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

returnY = nargout>1;

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

% Pre-allocate NaNs.
R = [R, nan(size(R, 1), ne*k)];
Y = [Y, nan(size(Y, 1), nh*k)];

% Expansion matrices not available.
if any(any(isnan(Xa)))
    return
end

% Jk = eye(size(J));
% for i = k0+1 : k
%     Ra = -Xa*Jk*Ru; % Jk stores J^(k-1).
%     Ya = -Xa*Jk*Yu;
%     Jk = Jk*J;
%     Rf = Xf*Jk*Ru;
%     Yf = Xf*Jk*Yu;
%     R(:, i*ne+(1:ne)) = [Rf;Ra];
%     Y(:, i*nh+(1:nh)) = [Yf;Ya];
% end

X = [ Xf*J ; -Xa ];
for i = 1 : k
    R(:, i*ne+(1:ne)) = X*Ru;
    Ru = J*Ru;
end

if returnY
    for i = 1 : k
        Y(:, i*nh+(1:nh)) = X*Yu;
        Yu = J*Yu;
    end
end

end
