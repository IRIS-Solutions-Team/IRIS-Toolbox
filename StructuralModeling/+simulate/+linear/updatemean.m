function Upd = updatemean(Z,Px,PErr)
% updatemean  [Not a public function] Mean update in conditioning systems.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Update X subject to Z X = Data and PErr = Data - Z X
% X = X + Upd
% Update Y, Y = M X
% Y = Y + M*Upd

%--------------------------------------------------------------------------

PxZt = Px * Z.';
F = Z*PxZt;
K = PxZt / F;
Upd = K*PErr;

end
