function steady = fillSteady(equation)
% fillSteady  Fill in empty steady equations with dynamic equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

ixm = equation.Type==1;
ixt = equation.Type==2;
ixmt = ixm | ixt;

ixEmpty = cellfun(@isempty, equation.Steady);
steady = equation.Steady;
steady(ixEmpty & ixmt) = equation.Dynamic(ixEmpty & ixmt);

end
