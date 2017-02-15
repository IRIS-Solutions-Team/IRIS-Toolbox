function opt = solver( )
% solver  Default options for solvers.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

FN_VALID = irisopt.validfn;

%--------------------------------------------------------------------------

opt = struct( );

steadyShared = { 
    'Display', 'iter*', FN_VALID.Display
    'MaxIterations, MaxIter', @default, @(x) isequal(x, @default) || (isnumericscalar(x) || round(x)==x || x>0)
    'MaxFunctionEvaluations, MaxFunEvals', @default, @(x) isequal(x, @default) || (isnumericscalar(x) && round(x)==x && x>0)
    'FiniteDifferenceStepSize', @default, @(x) isequal(x, @default) || (isnumericscalar(x) && x>0)
    'FiniteDifferenceType', 'forward', @(x) any(strcmpi(x, {'finite', 'central'}))
    'FunctionTolerance, TolFun', 1e-12, @(x) isnumericscalar(x) && x>0
    'SpecifyObjectiveGradient', false, @islogicalscalar
    'StepTolerance, TolX', 1e-12, @(x) isnumericscalar(x) && x>0
    };

opt.SteadyOptimTbx = [
    steadyShared
    {
    'Algorithm', 'levenberg-marquardt', @ischar
    'InitDamping', @default, @(x) isequal(x, @default) || (isnumericscalar(x) && x>=0)
    } ];

opt.SteadyIris = [
    steadyShared
    {
    'Algorithm', 'levenberg-marquardt', @(x) ischar(x) && any(strcmpi(x, {'levenberg-marquardt', 'lm'}))
    'StepUp', 1.2, @(x) isequal(x, false) || (isnumericscalar(x) && x>1)
    'StepDown', 0.8, @(x) isequal(x, false) || (isnumericscalar(x) && x>0 && x<1)
    } ];

end
