function [Y,Xx,Ea,Eu] = contributions(S,NPer)
% simulate.linear.contributions  Compute contributions of shocks, ...
% initial condition, const, and nonlinearities.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nx = size(S.T,1);
nb = size(S.T,2);
ne = size(S.Ea,1);
if isequal(NPer,Inf)
    NPer = size(S.Ea,2);
end

Y = zeros(ny,NPer,ne+2);
Xx = zeros(nx,NPer,ne+2); % := [xf;alp]

% Pre-allocate space for output contributions.
Ea = zeros(size(S.Ea,1),size(S.Ea,2),ne+2);
Eu = zeros(size(S.Eu,1),size(S.Eu,2),ne+2);

% Contributions of individual shocks.
isDeviation = S.IsDeviation;
S.IsDeviation = true;
alp0 = zeros(nb,1);
for ii = 1 : ne
    Ea(ii,:,ii) = S.Ea(ii,:);
    Eu(ii,:,ii) = S.Eu(ii,:);
    [y,xx] = simulate.linear.plain(S, ...
        S.IsDeviation,alp0,Ea(:,:,ii),Eu(:,:,ii),NPer);
    Y(:,:,ii) = y;
    Xx(:,:,ii) = xx;
end
S.IsDeviation = isDeviation;

% Contribution of initial condition and constant; no shocks included.
[y,xx] = simulate.linear.plain(S,S.IsDeviation,S.Alp0,[ ],[ ],NPer);
Y(:,:,ne+1) = y;
Xx(:,:,ne+1) = xx;

% Leave contributions of nonlinearities zeros.

end
