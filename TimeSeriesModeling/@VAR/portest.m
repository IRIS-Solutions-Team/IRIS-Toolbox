% portest  Portmanteau test for autocorrelation in VAR residuals.
%
% Syntax
% =======
%
%     [Stat,Crit] = portest(V,Data,H)
%
% Input arguments
% ================
%
% * `V` [ VAR | swar ] - Estimated VAR from which the tested residuals were
% obtained.
%
% * `Data` [ tseries ] - VAR residuals, or VAR output data including
% residuals, to be tested for autocorrelation.
%
% * `H` [ numeric ] - Test horizon; must be greater than the order of the
% tested VAR.
%
% Output arguments
% =================
%
% * `Stat` [ numeric ] - Portmanteau test statistic.
%
% * `Crit` [ numeric ] - Portmanteau test critical value based on
% chi-square distribution.
%
% Options
% ========
%
% * `'level='` [ numeric | *`0.05`* ] - Requested significance level for
% computing the criterion `Crit`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.


function [Stat,Crit] = portest(This,Inp,H,varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Level', 0.05, @(x) isnumeric(x) && isscalar(x) && x > 0 && x < 1);
end
parse(ip, varargin{:});
opt = ip.Results;

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

if H <= p
    utils.error('VAR', ...
        'Order of Portmonteau test must be higher than VAR order.');
end

% Request residuals.
req = datarequest('e*',This,Inp,This.Range);
e = req.E;
nData = size(e,3);
if nData ~= nAlt
    utils.error('VAR', ...
        'Number of parameterisations and number of data sets must match.');
end

% Orthonormalise residuals by Choleski factor of Omega.
for iAlt = 1 : nAlt
    P = chol(This.Omega(:,:,iAlt));
    e(:,:,iAlt) = P\e(:,:,iAlt);
end

% Test statistic.
Stat = zeros(1,nAlt);
for iAlt = 1 : nAlt
    fitted = This.IxFitted(1,:,iAlt);
    nObs = sum(fitted);
    ei = e(:,fitted,iAlt);
    for i = 1 : H
        Ci = ei(:,1+i:end)*ei(:,1:end-i)' / nObs;
        Stat(iAlt) = Stat(iAlt) + trace(Ci'*Ci) / (nObs-i);
    end
    Stat(iAlt) = (nObs^2) * Stat(iAlt);
end

% Critical value.
if nargout > 1
    Crit = chi2inv(1-opt.level,ny^2*(H-p));
end

end
