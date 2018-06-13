function This = infocrit(This)
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

nAlt = size(This.Omega,3);

This.Aic = nan(1,nAlt);
This.Sbc = nan(1,nAlt);

if all(~This.IxFitted(:)) || ~isfinite(This.NHyper)
    return
end

nFitted = nfitted(This);
for iAlt = 1 : nAlt
    if nFitted(iAlt) == 0
        continue
    end
    logDetOmg = log(det(This.Omega(:,:,iAlt)));
    This.Aic(iAlt) = logDetOmg + 2./nFitted(iAlt) * This.NHyper;
    This.Sbc(iAlt) = logDetOmg ...
        + log(nFitted(iAlt))./nFitted(iAlt) * This.NHyper;
end

end
