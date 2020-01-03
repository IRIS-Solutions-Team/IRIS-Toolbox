function steady = fillSteady(equation)
% fillSteady  Fill in empty steady equations with dynamic equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

ixm = equation.Type==TYPE(1);
ixt = equation.Type==TYPE(2);
ixmt = ixm | ixt;

ixEmpty = cellfun(@isempty, equation.Steady);
steady = equation.Steady;
steady(ixEmpty & ixmt) = equation.Dynamic(ixEmpty & ixmt);

end