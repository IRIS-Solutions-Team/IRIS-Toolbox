function [R, Y, Jk] = expandFirstOrder(this, variantRequested, k)
% expandFirstOrder  Expan first-order solution forward up to t+k for one parameter variant.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

returnY = nargout>1;
returnJk = nargout>2;

R = this.Variant.Solution{2}(:, :, variantRequested);
if returnY
    Y = this.Variant.Solution{8}(:, :, variantRequested);
end

Xa = this.Variant.Expansion{1}(:, :, variantRequested);
Xf = this.Variant.Expansion{2}(:, :, variantRequested);
Ru = this.Variant.Expansion{3}(:, :, variantRequested);
J  = this.Variant.Expansion{4}(:, :, variantRequested);
Jk = this.Variant.Expansion{5}(:, :, variantRequested);
if returnY
    Yu = this.Variant.Expansion{6}(:, :, variantRequested);
end

ne = size(Ru, 2);
if returnY
    nn = size(Yu, 2);
else
    nn = 0;
end

if ne==0 && nn==0
    return
end

% Current expansion available up to t+k0.
k0 = size(R, 2)/ne - 1;

% Requested expansion no longer than the existing.
if k0>=k
    return
end

% Pre-allocate NaNs.
R(:, end+1:ne*(1+k)) = NaN;
if returnY
    Y(:, end+1:nn*(1+k)) = NaN;
end

% Expansion matrices not available.
if any(any(isnan(Xa)))
    return
end

% for i = k0+1 : k
%     Ra = -Xa*Jk*Ru; % Jk stores J^(k-1).
%     Ya = -Xa*Jk*Yu;
%     Jk = Jk*J;
%     Rf = Xf*Jk*Ru;
%     Yf = Xf*Jk*Yu;
%     R(:, i*ne+(1:ne)) = [Rf;Ra];
%     Y(:, i*nn+(1:nn)) = [Yf;Ya];
% end

X = [ Xf*Jk*J ; -Xa*Jk ];
for i = k0+1 : k
    R(:, i*ne+(1:ne)) = X*Ru;
    Ru = J*Ru;
end

if returnY
    for i = k0+1 : k
        Y(:, i*nn+(1:nn)) = X*Yu;
        Yu = J*Yu;
    end
end

if returnJk
    Jk = Jk*J^(k-k0);
end

end
