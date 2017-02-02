function this = preallocate(this, n)

ny = n(1);
nx = n(2);
ne = n(3);
try nf = n(4); catch, nf = 0; end
try nn = n(5); catch, nn = 0; end
nb = nx - nf;
this.T = nan(nf+nb, nb); % T
this.R = nan(nf+nb, ne); % R
this.k = nan(nf+nb, 1); % K
this.Z = nan(ny, nb); % Z
this.H = nan(ny, ne); % H
this.d = nan(ny, 1); % D
this.U = nan(nb, nb); % U
this.Y = nan(nf+nb, nn); % Y - Nonlin addfactors.
this.ZZ = nan(ny, nb); % ZZ - Untransformed measurement.

end