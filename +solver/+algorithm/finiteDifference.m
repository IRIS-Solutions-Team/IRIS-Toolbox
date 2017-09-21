function [g, addCount] = finiteDifference(objectiveFunc, x, f, step, jacobPattern)
% finiteDifference  Forward finite difference.
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
g = zeros(nf, nx);

if isempty(jacobPattern)
    % Evaluate all equations for all quantities regardless of the Jacobian
    % pattern.
    for i = 1 : nx
        xp = x;
        xp(i) = xp(i) + h(i);
        fnPlus = objectiveFunc(xp);
        g(:, i) = (fnPlus - f) / h(i);
    end
else
    % Evaluate equations based on the Jacobian pattern (large scale
    % problems).
    for i = 1 : nx
        indexOfEquations = jacobPattern(:, i);
        xp = x;
        xp(i) = xp(i) + h(i);
        fnPlus = objectiveFunc(xp, i);
        g(indexOfEquations, i) = (fnPlus - f(indexOfEquations)) / h(i);
    end
end

addCount = nx;

end
