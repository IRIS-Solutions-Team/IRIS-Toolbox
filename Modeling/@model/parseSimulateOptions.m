function opt = parseSimulateOptions(this, varargin)
% parseSimulateOptions  Parse options for model.simulate
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model.parseSimulateOptions');

    inputParser.addDeviationOptions(false);
    inputParser.addDisplayOption(@auto);

    inputParser.addParameter('Anticipate', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'AppendPresample', 'AddPresample'}, false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'AppendPostsample', 'AddPostsample'}, false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Blocks', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'Contributions', 'Contribution'}, false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'DbOverlay', 'DbExtend'}, false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    inputParser.addParameter('Delog', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Fast', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'IgnoreShocks', 'IgnoreShock'}, false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Method', 'FirstOrder', @(x) ischar(x) && any(strcmpi(x, {'FirstOrder', 'Selective', 'Global', 'Exact', 'Stacked', 'Period'})));
    inputParser.addParameter('Missing', NaN, @isnumeric);
    inputParser.addParameter('Plan', [ ], @(x) isa(x, 'plan') || isa(x, 'Plan') || isempty(x));
    inputParser.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'SparseShocks', 'SparseShock'}, false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'Revision', 'Revisions'}, false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('SystemProperty', false, @(x) isequal(x, false) || ((ischar(x) || isa(x, 'string') || iscellstr(x)) && ~isempty(x)));

    inputParser.addParameter('Error', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('PrepareGradient', @auto, @(x) isequal(x, true) || isequal(x, false) || isequal(x, @auto));
    inputParser.addParameter('OptimSet', cell.empty(1, 0), @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x));
    inputParser.addParameter('Solver', @auto, @validateSolver);
    
    % Equation Selective Method Options
    inputParser.addParameter({'NonlinWindow', 'NonlinPer'}, @all, @(x) isequal(x, @all) || (isnumeric(x) && isscalar(x) && x>=0));
    inputParser.addParameter('MaxNumelJv', 1e6, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);

    % Equation Selective Options -- QaD Algorithm
    inputParser.addParameter({'AddSteady', 'AddSstate'}, true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('FillOut', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Lambda', 1, @(x) isnumeric(x) && isscalar(x) && all(x>0 & x<=2));
    inputParser.addParameter({'NOptimLambda', 'OptimLambda'}, 1, @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=0));
    inputParser.addParameter({'ReduceLambda', 'LambdaFactor'}, 0.5, @(x) isnumeric(x) && isscalar(x) && x>0 && x<=1);
    inputParser.addParameter('MaxIter', 100, @(x) isnumeric(x) && isscalar(x) && x>=0);
    inputParser.addParameter('NShanks', false, @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x==round(x) && x>0) || isequal(x, false));
    inputParser.addParameter('Tolerance', 1e-5, @(x) isnumeric(x) && isscalar(x));
    inputParser.addParameter('UpperBound', 1.5, @(x) isnumeric(x) && isscalar(x) && all(x>1));
    
    % TODO Consolidate the following options
    % Global Nonlinear Simulations
    inputParser.addParameter('ChkSstate', true, @model.validateChksstate);
    inputParser.addParameter('ForceRediff', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('InitEndog', 'Dynamic', @(x) ischar(x) && any(strcmpi(x, {'Dynamic', 'Static'})));
    inputParser.addParameter('Solve', true, @model.validateSolve);
    inputParser.addParameter({'Steady', 'Sstate', 'SstateOpt'}, true, @model.validateSstate);
    inputParser.addParameter('Unlog', [ ], @(x) isempty(x) || isequal(x, @all) || iscellstr(x) || ischar(x));
end
inputParser.parse(varargin{:});
opt = inputParser.Options;

end%


function flag = validateSolver(x)
    flag = isequal(x, @auto) ...
        || (ischar(x) && any(strcmpi(x, {'qad', 'plain', 'lsqnonlin', 'IRIS', 'fsolve'}))) ...
        || isequal(x, @fsolve) || isequal(x, @lsqnonlin) || isequal(x, @qad) ...
        || (iscell(x) && iscellstr(x(2:2:end))) ;
end%

