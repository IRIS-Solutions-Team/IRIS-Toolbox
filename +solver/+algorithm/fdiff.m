function [g, addCount] = fdiff(fnObjective, x, f, step)
% fdiff  Forward finite difference.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

z = abs(x);
z(z<1) = 1;
h = step*z;

nf = numel(f);
nx = numel(x);
g = nan(nf, nx);

for i = 1 : nx
    xp = x;
    xp(i) = xp(i) + h(i);
    g(:, i) = (fnObjective(xp) - f) / h(i);
end

addCount = nx;

end
