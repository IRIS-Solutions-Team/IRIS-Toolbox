function [S, C] = myresponse(This,Time,Phi0,Select,Opt)
% srf  Shock (impulse) response function.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Tell if `Time` is `NPer` or `Range`.
[range,nPer] = BaseVAR.mytelltime(Time);

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);
nSelect = sum(Select);

% Compute VMA matrices.
Phi = timedom.var2vma(This.A,Phi0,nPer,Select);

% Create shock paths.
Eps = zeros(ny,nSelect,nPer,nAlt);
for iAlt = 1 : nAlt
    E = eye(ny);
    E = E(:,Select);
    Eps(:,:,1,iAlt) = E;
end

% Permute dimensions so that time runs along the 2nd dimension.
Phi = permute(Phi,[1,3,2,4]);
Eps = permute(Eps,[1,3,2,4]);

% Add a total of `p` zero initial conditions.
if Opt.presample
    Phi = [zeros(ny,p,nSelect,nAlt),Phi];
    Eps = [zeros(ny,p,nSelect,nAlt),Eps];
    xRange = range(1)-p : range(end);
else
    xRange = range;
end

names = [This.EndogenousNames, This.ResidualNames];
S = myoutpdata( This, xRange, [Phi; Eps], [ ], names);
if nargout>1
    Psi = cumsum(Phi, 2);
    C = myoutpdata( This, xRange, [Psi; Eps], [ ], names);
end

end
