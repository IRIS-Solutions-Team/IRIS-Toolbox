function Upd = updatemse(Z,Px)
% updatemse [Not a public function] MSE update in conditioning systems.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Update Px = Cov(X) subject to Z X = fixed
% Px = Px - Upd
% Update Cov(Y), Y = M X
% Py = Py - M Upd M'

%--------------------------------------------------------------------------

PxZt = Px * Z.';
F = Z*PxZt;
K = PxZt / F;
Upd = K*Z*Px;
Upd = (Upd + Upd')/2;

end
