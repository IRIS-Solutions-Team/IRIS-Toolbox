function [R,Y,Jk] = myexpand(R,Y,k,Xa,Xf,Ru,J,Jk,Yu)
% myexpand  [Not a public function] Expand one existing solution forward up to t+k.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% If one of the non-lin add-factor matrices has been entered as an empty
% array, do not expand non-lin add-factors.
if all(size(Y)) == 0 || all(size(Yu) == 0)
    Y = zeros(size(R,1),0);
    Yu = zeros(size(Ru,1),0);
end

ne = size(Ru,2);
nn = size(Yu,2);

if ne == 0 && nn == 0
    return
end

% Current expansion available up to t+k0.
k0 = size(R,2)/ne - 1;

% Check that R and Y are expanded to the same horizon.
if nn > 0 && k0 ~= size(Y,2)/nn - 1
    utils.error('model:myexpand','#Internal');
end

% Requested expansion not longer than the existing.
if k0 >= k
    return
end

% Pre-allocate NaNs.
R(:,end+(1:ne*(k-k0))) = NaN;
Y(:,end+(1:nn*(k-k0))) = NaN;

% Expansion matrices not available.
if any(any(isnan(Xa)))
    return
end

% Compute expansion.
% for i = k0+1 : k
%     Ra = -Xa*Jk*Ru; % Jk stores J^(k-1).
%     Ya = -Xa*Jk*Yu;
%     Jk = Jk*J;
%     Rf = Xf*Jk*Ru;
%     Yf = Xf*Jk*Yu;
%     R(:,i*ne+(1:ne)) = [Rf;Ra];
%     Y(:,i*nn+(1:nn)) = [Yf;Ya];
% end

X = [ Xf*Jk*J ; -Xa*Jk ];
for i = k0+1 : k
    R(:,i*ne+(1:ne)) = X*Ru;
    Y(:,i*nn+(1:nn)) = X*Yu;
    Ru = J*Ru;
    Yu = J*Yu;
end

if nargout > 2
    Jk = Jk*J^(k-k0);
end


end