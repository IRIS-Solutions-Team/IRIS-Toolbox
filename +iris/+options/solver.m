function opt = solver( )
% solver  Default options for IRIS solvers
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

opt = struct( );

shared = { 
    'Display', 'iter*', @solver.Options.validateDisplay
    'JacobPattern', [ ], @(x) isempty(x) || (islogical(x) && issparse(x)) 
    'MaxIterations, MaxIter', @default, @(x) isequal(x, @default) || (isnumericscalar(x) || round(x)==x || x>0)
    'MaxFunctionEvaluations, MaxFunEvals', @default, @(x) isequal(x, @default) || isa(x, 'function_handle') || (isnumericscalar(x) && round(x)==x && x>0)
    'FiniteDifferenceStepSize', @default, @(x) isequal(x, @default) || (isnumericscalar(x) && x>0)
    'FiniteDifferenceType', 'forward', @(x) any(strcmpi(x, {'finite', 'central'}))
    'FunctionTolerance, TolFun', model.DEFAULT_STEADY_TOLERANCE, @(x) isnumericscalar(x) && x>0
    'StepTolerance, TolX', model.DEFAULT_STEADY_TOLERANCE, @(x) isnumericscalar(x) && x>0
};

optimShared = {
    'Algorithm', 'levenberg-marquardt', @ischar
    'InitDamping', @default, @(x) isequal(x, @default) || (isnumericscalar(x) && x>=0)
};

irisShared = {
    'Algorithm', 'levenberg-marquardt', @(x) ischar(x) && any(strcmpi(x, {'levenberg-marquardt', 'lm'}))
    'FunctionNorm', 2, @(x) isequal(x, 1) || isequal(x, 2) || isequal(x, Inf) || isa(x, 'function_handle')
    'Lambda', [0.01, 1, 100], @(x) isnumeric(x) && all(x>0) && all(isreal(x))
    'LargeScale', false, @(x) isequal(x, true) || isequal(x, false)
    'StepUp', 1.2, @(x) isequal(x, false) || (isnumericscalar(x) && x>1)
    'StepDown', 0.8, @(x) isequal(x, false) || (isnumericscalar(x) && x>0 && x<1)
};

steadyShared = {
    'SpecifyObjectiveGradient', true, @(x) isequal(x, true) || isequal(x, false)
};

selectiveShared = {
    'SpecifyObjectiveGradient', false, @(x) isequal(x, true) || isequal(x, false)
};

irisSelective = {
    'Lambda', [ ], @(x) isnumeric(x) && all(x>0) && all(isreal(x))
};

exactShared = steadyShared;

stackedShared = {
    'SpecifyObjectiveGradient', false, @(x) isequal(x, true) || isequal(x, false)
};

opt.OptimSteady = [
    shared
    optimShared
    steadyShared
];

opt.OptimExact = [
    shared
    optimShared
    exactShared
];

opt.OptimStacked = [
    shared
    optimShared
    stackedShared
];

opt.OptimSelective = [
    shared
    optimShared
    selectiveShared
];

opt.IrisSteady = [
    shared
    irisShared
    steadyShared
];

opt.IrisExact = [
    shared
    irisShared
    exactShared
];

opt.IrisStacked = [
    shared
    irisShared
    stackedShared
];

opt.IrisSelective = [
    shared
    irisShared
    selectiveShared
    irisSelective
];

end
