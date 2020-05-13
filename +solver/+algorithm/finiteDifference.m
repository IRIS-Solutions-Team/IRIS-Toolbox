function [g, addCount] = finiteDifference(objectiveFuncReshaped, x, f, step, jacobPattern, largeScale)
% finiteDifference  Forward finite difference
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

z = abs(x);
z(z<1) = 1;
h = step*z;

nf = numel(f);
nx = numel(x);

if ~largeScale
    % Evaluate all equations for all quantities regardless of the Jacobian
    % pattern
    g = zeros(nf, nx);
    for i = 1 : nx
        xp = x;
        xp(i) = xp(i) + h(i);
        fnPlus = objectiveFuncReshaped(xp);
        fnPlus = fnPlus(:);
        g(:, i) = (fnPlus - f) / h(i);
    end
else
    % Evaluate equations based on the Jacobian pattern (large scale
    % problems). Objective function is expected to return only the
    % derivatives indicated in the Jacobian pattern matrix.
    g = sparse(nf, nx);
    for i = 1 : nx
        inxEquations = jacobPattern(:, i);
        xp = x;
        xp(i) = xp(i) + h(i);
        fnPlus = objectiveFuncReshaped(xp, i);
        fnPlus = fnPlus(:);
        % TODO: Replace sparse matrix indexing
        g(inxEquations, i) = (fnPlus - f(inxEquations)) / h(i);
    end
end

addCount = nx;

end%

