% parseSimulateOptions  Parse options for model.simulate
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [opt, legacyOpt] = parseSimulateOptions(this, varargin)

persistent ip 
if isempty(ip)
    ip = extend.InputParser();
    ip.KeepUnmatched = true;

    ip.addParameter('Deviation', false, @validate.logicalScalar);
    ip.addParameter('EvalTrends', logical.empty(1, 0));

    ip.addParameter('Anticipate', true, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter({'AppendPresample', 'AddPresample'}, false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter({'AppendPostsample', 'AddPostsample'}, false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('Blocks', true, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter({'Contributions', 'Contribution'}, false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter({'DbOverlay', 'DbExtend'}, false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    ip.addParameter('Delog', true, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('Fast', true, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter({'IgnoreShocks', 'IgnoreShock'}, false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('Method', 'FirstOrder', @(x) ischar(x) && any(strcmpi(x, {'FirstOrder', 'Selective'})));
    ip.addParameter('Missing', NaN, @isnumeric);
    ip.addParameter('Plan', [ ], @(x) isa(x, 'plan') || isa(x, 'Plan') || isempty(x));
    ip.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter({'SparseShocks', 'SparseShock'}, false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('SystemProperty', false, @(x) isequal(x, false) || (ischar(x) || isstring(x) || iscellstr(x)));

    ip.addParameter('Error', false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('PrepareGradient', @auto, @(x) isequal(x, true) || isequal(x, false) || isequal(x, @auto));
    ip.addParameter('Solver', @auto, @local_validateSolverOption);
    
    % Equation Selective Method Options
    ip.addParameter({'NonlinWindow', 'NonlinPer'}, @all, @(x) isequal(x, @all) || (isnumeric(x) && isscalar(x) && x>=0));
    ip.addParameter('MaxNumelJv', 1e6, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);

    % Equation Selective Options -- QaD Algorithm
    ip.addParameter({'AddSteady', 'AddSstate'}, true, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('FillOut', false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter({'NOptimLambda', 'OptimLambda'}, 1, @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=0));
    ip.addParameter('ReduceLambda', 0.5, @(x) isnumeric(x) && isscalar(x) && x>0 && x<=1);
    ip.addParameter('NShanks', false, @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x==round(x) && x>0) || isequal(x, false));
    ip.addParameter('UpperBound', 1.5, @(x) isnumeric(x) && isscalar(x) && all(x>1));
    
    % Stacked Time Method
    ip.addParameter('Initial', 'FirstOrder', @(x) any(strcmpi(x, {'InputData', 'FirstOrder'})));

    % TODO Consolidate the following options
    % Global Nonlinear Simulations
    ip.addParameter('ChkSstate', true, @model.validateChksstate);
    ip.addParameter('InitEndog', 'Dynamic', @(x) ischar(x) && any(strcmpi(x, {'Dynamic', 'Static'})));
    ip.addParameter('Solve', true, @model.validateSolve);
    ip.addParameter({'Steady', 'Sstate', 'SstateOpt'}, true, @model.validateSteady);
    ip.addParameter('Unlog', [ ], @(x) isempty(x) || isequal(x, @all) || iscellstr(x) || ischar(x) || isstring(x));
end

opt = parse(ip, varargin{:});
legacyOpt = ip.UnmatchedInCell;

if isempty(opt.EvalTrends)
    opt.EvalTrends = ~opt.Deviation;
end

end%


function flag = local_validateSolverOption(x)
    flag = isequal(x, @auto) || local_validateSolverName(x) ...
           || (iscell(x) && local_validateSolverName(x{1}) && iscellstr(x(2:2:end)));
end%


function flag = local_validateSolverName(x)
    flag = (ischar(x) && any(strcmpi(x, {'IRIS-qad', 'IRIS-qnsd', 'IRIS-newton', 'qad', 'IRIS', 'lsqnonlin', 'fsolve'}))) ...
           || isequal(x, @fsolve) || isequal(x, @lsqnonlin) || isequal(x, @qad);
end%

