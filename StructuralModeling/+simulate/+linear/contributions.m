function [y, xx, ea, eu] = contributions(s, numOfPeriods)
% contributions  Compute contributions of shocks, initial condition, const, and nonlinearities
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = size(s.Z, 1);
nx = size(s.T, 1);
nb = size(s.T, 2);
ne = size(s.Ea, 1);
if isequal(numOfPeriods, Inf)
    numOfPeriods = size(s.Ea, 2);
end

y = zeros(ny, numOfPeriods, ne+2);
xx = zeros(nx, numOfPeriods, ne+2); % := [xf;alp]

% Pre-allocate space for output contributions
ea = zeros(size(s.Ea, 1), size(s.Ea, 2), ne+2);
eu = zeros(size(s.Eu, 1), size(s.Eu, 2), ne+2);

% Contributions of individual shocks
isDeviation = s.IsDeviation;
s.IsDeviation = true;
alp0 = zeros(nb, 1);
for ii = 1 : ne
    ea(ii, :, ii) = s.Ea(ii, :);
    eu(ii, :, ii) = s.Eu(ii, :);
    [yi, xxi] = simulate.linear.plain( s, s.IsDeviation, alp0, ...
                                       ea(:, :, ii), eu(:, :, ii), numOfPeriods );
    y(:, :, ii) = yi;
    xx(:, :, ii) = xxi;
end
s.IsDeviation = isDeviation;

% Contribution of initial condition and constant; no shocks included
[yi, xxi] = simulate.linear.plain(s, s.IsDeviation, s.Alp0, [ ], [ ], numOfPeriods);
y(:, :, ne+1) = yi;
xx(:, :, ne+1) = xxi;

% Leave contributions of nonlinearities zeros

end
