function This = myprealloc(This,Ny,P,NXPer,NAlt,Ng)
% myprealloc  [Not a public function] Pre-allocate VAR matrices before estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

This = myprealloc@varobj(This,Ny,P,NXPer,NAlt);
nGrp = max(1,length(This.GroupNames));
nx = length(This.NamesExogenous);

This.K = nan(Ny,nGrp,NAlt);
This.G = nan(Ny,Ng,NAlt);
This.T = nan(Ny*P,Ny*P,NAlt);
This.U = nan(Ny*P,Ny*P,NAlt);
This.Sigma = [ ];
This.Aic = nan(1,NAlt);
This.Sbc = nan(1,NAlt);
This.Zi = zeros(0,Ny*P+1);
This.J = nan(Ny,nGrp*nx,NAlt);
This.X0 = nan(nx,nGrp,NAlt);

end