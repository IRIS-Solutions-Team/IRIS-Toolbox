function [opt, legacyOpt] = parseSimulateOptions(this, varargin)
% parseSimulateOptions  Parse options for model.simulate
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser 

if isempty(parser)
    parser = extend.InputParser('model.simulate');
    parser.KeepUnmatched = true;

    parser.addDeviationOptions(false);

    parser.addParameter('Anticipate', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'AppendPresample', 'AddPresample'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'AppendPostsample', 'AddPostsample'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Blocks', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'Contributions', 'Contribution'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'DbOverlay', 'DbExtend'}, false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    parser.addParameter('Delog', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Fast', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'IgnoreShocks', 'IgnoreShock'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Method', 'FirstOrder', @(x) ischar(x) && any(strcmpi(x, {'FirstOrder', 'Selective'})));
    parser.addParameter('Missing', NaN, @isnumeric);
    parser.addParameter('Plan', [ ], @(x) isa(x, 'plan') || isa(x, 'Plan') || isempty(x));
    parser.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'SparseShocks', 'SparseShock'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('SystemProperty', false, @(x) isequal(x, false) || ((ischar(x) || isa(x, 'string') || iscellstr(x)) && ~isempty(x)));

    parser.addParameter('Error', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('PrepareGradient', @auto, @(x) isequal(x, true) || isequal(x, false) || isequal(x, @auto));
    parser.addParameter('Solver', @auto, @validateSolverOption);
    
    % Equation Selective Method Options
    parser.addParameter({'NonlinWindow', 'NonlinPer'}, @all, @(x) isequal(x, @all) || (isnumeric(x) && isscalar(x) && x>=0));
    parser.addParameter('MaxNumelJv', 1e6, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);

    % Equation Selective Options -- QaD Algorithm
    parser.addParameter({'AddSteady', 'AddSstate'}, true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('FillOut', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'NOptimLambda', 'OptimLambda'}, 1, @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=0));
    parser.addParameter('ReduceLambda', 0.5, @(x) isnumeric(x) && isscalar(x) && x>0 && x<=1);
    parser.addParameter('NShanks', false, @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x==round(x) && x>0) || isequal(x, false));
    parser.addParameter('UpperBound', 1.5, @(x) isnumeric(x) && isscalar(x) && all(x>1));
    
    % Stacked Time Method
    parser.addParameter('Initial', 'FirstOrder', @(x) any(strcmpi(x, {'InputData', 'FirstOrder'})));

    % TODO Consolidate the following options
    % Global Nonlinear Simulations
    parser.addParameter('ChkSstate', true, @model.validateChksstate);
    parser.addParameter('ForceRediff', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('InitEndog', 'Dynamic', @(x) ischar(x) && any(strcmpi(x, {'Dynamic', 'Static'})));
    parser.addParameter('Solve', true, @model.validateSolve);
    parser.addParameter({'Steady', 'Sstate', 'SstateOpt'}, true, @model.validateSstate);
    parser.addParameter('Unlog', [ ], @(x) isempty(x) || isequal(x, @all) || iscellstr(x) || ischar(x));
end

parse(parser, varargin{:});
opt = parser.Options;
legacyOpt = parser.UnmatchedInCell;

end%


function flag = validateSolverOption(x)
    flag = isequal(x, @auto) || validateSolverName(x) ...
           || (iscell(x) && validateSolverName(x{1}) && iscellstr(x(2:2:end)));
end%


function flag = validateSolverName(x)
    flag = (ischar(x) && any(strcmpi(x, {'IRIS-qad', 'IRIS-qnsd', 'IRIS-newton', 'qad', 'IRIS', 'lsqnonlin', 'fsolve'}))) ...
           || isequal(x, @fsolve) || isequal(x, @lsqnonlin) || isequal(x, @qad);
end%

