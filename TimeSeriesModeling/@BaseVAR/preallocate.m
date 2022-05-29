% preallocate  Preallocate VAR matrices before estimation
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = preallocate(this, numEndogenous, order, numExtdPeriods, nv)

numGroups = max(1, this.NumGroups);
this.A = nan(numEndogenous, numEndogenous*order, nv);
this.Omega = nan(numEndogenous, numEndogenous, nv);
this.EigVal = nan(1, numEndogenous*order, nv);
this.IxFitted = false(numGroups, numExtdPeriods, nv);

end%

