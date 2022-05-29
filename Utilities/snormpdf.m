function [F,Mu,Sgm] = snormpdf(X,Ex,Sx,Tau)
% snormpdf  Probability density function for univariate split normal
% distribution.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

% x ~ N(mu,sigma) for x <= mu
% x ~ N(mu,tau*sigma) for x > mu

Sx2 = Sx^2;
b = (pi-2)/pi*(Tau - 1)^2 + Tau;
sigma2 = Sx2/b;
Sgm = sqrt(sigma2);
Mu = Ex - sqrt(2/pi)*Sgm*(Tau - 1);

F = nan(size(X));
if ~isempty(X)
    index = X <= Mu;
    F(index) = 1/(1+Tau)*normpdf(X(index),Mu,Sgm);
    F(~index) = Tau/(1+Tau)*normpdf(X(~index),Mu,Tau*Sgm);
end

end
