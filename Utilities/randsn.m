function R = randsn(Dim,Ex,Sx,Tau)
% randsn  Split-normally distributed random numbers.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[~,mu,sigma] = snormpdf([ ],Ex,Sx,Tau);

R = sigma*randn(Dim);
index = rand(Dim) <= 1/(1 + Tau);
R(index) = -abs(R(index));
R(~index) = Tau*abs(R(~index));
R = R + mu;

end
