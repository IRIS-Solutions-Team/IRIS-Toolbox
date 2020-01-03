function [g, addCount] = centralDifference(fnObjective, x, f, step)
% centralDifference  Central finite difference.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

z = abs(x);
z(z<1) = 1;
h = step*z;

nf = numel(f);
nx = numel(x);
g = zeros(nf, nx);

for i = 1 : nx
    xp = x;
    xm = x;
    xp(i) = xp(i) + h(i);
    xm(i) = xm(i) - h(i);
    step = xp(i) - xm(i);
    [fnPlus, ~, ~, indexOfEquations] = fnObjective(xp, i);
    fnMinus = fnObjective(xm, i);
    g(indexOfEquations, i) = (fnPlus - fnMinus) / step;
end

addCount = 2*nx;

end
