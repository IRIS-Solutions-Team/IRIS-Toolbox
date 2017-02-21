function [g, addCount] = cdiff(fnObjective, x, f, step)
% cdiff  Central finite difference.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

maxXOr1 = x;
maxXOr1(x<1) = 1;
h = step*maxXOr1;

nf = numel(f);
nx = numel(x);
g = nan(nf, nx);

for i = 1 : nx
    xp = x;
    xm = x;
    xp(i) = xp(i) + h(i);
    xm(i) = xm(i) - h(i);
    step = xp(i) - xm(i);
    g(:, i) = (fnObjective(xp) - fnObjective(xm)) / step;
end

addCount = 2*nx;

end
