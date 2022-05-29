function [Stat,Crit] = lrtest(V1,V2,Level)
% lrtest  Likelihood ratio test for VAR models.
%
% Syntax
% =======
%
%     [Stat,Crit] = lrtest(V1,V2,Level)
%
% Input arguments
% ================
%
% * `V1` [ VAR ] - Unrestricted VAR model.
%
% * `V2` [ VAR ] - Restricted VAR model.
%
% * `Level` [ numeric ] - Significance level; if not specified,
% 5 percent significance is used, `Level=0.05`.
%
% Output arguments
% =================
%
% * `Stat` [ numeric ] - LR test stastic.
%
% * `Crit` [ numeric ] - LR test critical value based on chi-square
% distribution.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    Level; %#ok<VUNUS>
catch %#ok<CTCH>
    Level = 0.05;
end

%--------------------------------------------------------------------------

nAlt2 = size(V2.A,3);
nAlt1 = size(V1.A,3);
nAlt = max(nAlt1,nAlt2);

if V1.NHyper == V2.NHyper
    utils.warning('VAR', ...
        ['LR-tested VAR objects have ', ...
        'identical numbers of free parameters.']);
end

% Check the number of hyperparameters, and swap restricted and unrestricted
% VARs if needed.
if V1.NHyper < V2.NHyper
    [V1,V2] = deal(V2,V1);
end

% Fitted periods must the same in both VARs.
if any(~rngcmp(V1,V2))
    utils.error('VAR', ...
        ['LR-tested pairs of VAR objects must have ', ...
        'the same periods fitted.']);
end

nPer = nfitted(V1);
Stat = nan(1,nAlt);
for iAlt = 1 : nAlt
    if iAlt <= nAlt2
        iLogDetOmg2 = log(det(V2.Omega(:,:,iAlt)));
    end
    if iAlt <= nAlt1
        iLogDetOmg1 = log(det(V1.Omega(:,:,iAlt)));
        iNPer = nPer(iAlt);
    end
    Stat(iAlt) = iNPer*(iLogDetOmg2 - iLogDetOmg1);
end

% Critical value.
if nargout > 1
    Crit = chi2inv(1-Level,V1.NHyper-V2.NHyper);
end

end
