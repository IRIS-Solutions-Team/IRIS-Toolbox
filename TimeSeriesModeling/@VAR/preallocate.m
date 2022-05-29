% preallocate  Preallocate VAR matrices before estimation
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = preallocate(this, numEndogenous, order, numExtdPeriods, nv, numCointeg)

this = preallocate@BaseVAR(this, numEndogenous, order, numExtdPeriods, nv);
numGroups = max(1, this.NumGroups);
numExogenous = this.NumExogenous;

this.K = nan(numEndogenous, numGroups, nv);
this.G = nan(numEndogenous, numCointeg, nv);
this.T = nan(numEndogenous*order, numEndogenous*order, nv);
this.U = nan(numEndogenous*order, numEndogenous*order, nv);
this.Sigma = [ ];
this.Aic = nan(1, nv);
this.Sbc = nan(1, nv);
this.Zi = zeros(0, numEndogenous*order+1);
this.J = nan(numEndogenous, numGroups*numExogenous, nv);
this.X0 = nan(numExogenous, numGroups, nv);

end%

