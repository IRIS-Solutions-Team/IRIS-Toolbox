function this = infocrit(this)
% infocrit  Populate information criteria for a parameterised VAR.
%
% Syntax
% =======
%
%     V = infocrit(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with the AIC and SBC information criteria
% re-calculated.
%
% Description
% ============
%
% In most cases, you don't have to run the function `infocrit` as it is
% called from within `estimate` immediately after a new parameterisation is
% created.
%
% Example
% =======
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

nv = size(this.Omega, 3);

this.AIC = nan(1, nv);
this.SBC = nan(1, nv);

if all(~this.IxFitted(:)) || ~isfinite(this.NHyper)
    return
end

numFitted = nfitted(this);
K = this.NHyper;
for v = 1 : nv
    T = numFitted(v);
    if T==0
        continue
    end
    logDetOmg = log(det(this.Omega(:, :, v)));
    this.AIC(v) = logDetOmg + 2*K/T;
    this.AICc(v) = this.AIC(v) + 2*K*(K+1)/(T-K-1);
    this.SBC(v) = logDetOmg + log(T)*K/T;
end

end%

