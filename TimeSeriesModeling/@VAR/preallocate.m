% preallocate  Preallocate VAR matrices before estimation

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
    this.J = nan(numEndogenous, numGroups*numExogenous, nv);
    this.X0 = nan(numExogenous, numGroups, nv);

end%

