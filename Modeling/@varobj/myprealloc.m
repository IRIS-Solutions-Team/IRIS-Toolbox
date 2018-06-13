function This = myprealloc(This,Ny,P,NXPer,NAlt)
% myprealloc  [Not a public function] Pre-allocate VAR matrices before estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

nGrp = max(1,length(This.GroupNames));

This.A = nan(Ny,Ny*P,NAlt);
This.Omega = nan(Ny,Ny,NAlt);
This.EigVal = nan(1,Ny*P,NAlt);
This.IxFitted = false(nGrp,NXPer,NAlt);

end
