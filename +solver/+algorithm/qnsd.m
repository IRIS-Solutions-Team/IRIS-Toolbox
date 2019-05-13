function [x, f, exitFlag] = qnsd(objectiveFunc, xInit, opt, header)
% qnsd  Quasi-Newton-Steepest-Descent algorithm
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

FORMAT_HEADER = '%6s %8s %13s %6s %13s %13s %13s %13s';
FORMAT_ITER   = '%6g %8g %13g %6g %13g %13g %13g %13g%s';
MIN_STEP = 1e-8;
MAX_STEP = 2;
MAX_ITER_IMPROVE_PROGRESS = 40;
MAX_ITER_MAKE_PROGRESS = 40;
DEFAULT_STEP_SIZE = 1;
NUM_OF_OPTIM_STEP_SIZES = 10;

ITER_STRUCT = struct( 'Iter',     NaN, ...
                      'X',        NaN, ...
                      'MaxXChng', NaN, ...
                      'F',        NaN, ...
                      'J',        NaN, ...
                      'Lambda',   NaN, ...
                      'D',        NaN, ...
                      'Norm',     NaN, ...
                      'Step',     NaN, ...
                      'Reverse',  false );

%--------------------------------------------------------------------------

desktopStatus = iris.get('DesktopStatus');
maxChgFunc = @(x, x0) full(max(abs(x(:)-x0(:))));

vecOfLambdas = opt.Lambda;
vecOfLambdas(vecOfLambdas==0) = [ ];
if isempty(vecOfLambdas)
    stepType = 'Newton';
else
    stepType = 'Hybrid';
end

if isa(opt.FunctionNorm, 'function_handle')
    fnNorm = opt.FunctionNorm;
    strFnNorm = func2str(fnNorm);
    strFnNorm = regexprep(strFnNorm, '^@\(.*?\)', '', 'once');
    if length(strFnNorm)>12
        strFnNorm = strFnNorm(1:12);
    end
else
    fnNorm = @(x) norm(x, opt.FunctionNorm);
    strFnNorm = sprintf('norm(x,%g)', opt.FunctionNorm);
end
if opt.SpecifyObjectiveGradient
    strJacobNorm = 'Analytical';
else
    strJacobNorm = 'Numerical';
end
lastStepSizeOptim = opt.LastStepSizeOptim;
if ~isempty(vecOfLambdas)
    % Never optimize Hybrid step size
    lastStepSizeOptim = 0;
end

deflateStep = opt.DeflateStep;
inflateStep = opt.InflateStep;
doTryMakeProgress = ~isequal(deflateStep, false);
doTryImproveProgress = ~isequal(inflateStep, false);
diffStep = opt.FiniteDifferenceStepSize;
if ~opt.SpecifyObjectiveGradient
    jacobPattern = opt.JacobPattern;
end
lastJacobUpdate = opt.LastJacobUpdate;

sizeOfX = size(xInit);
if any(sizeOfX(2:end)>1)
    objectiveFuncReshaped = @(x, varargin) objectiveFunc(reshape(x, sizeOfX), varargin{:});
else
    objectiveFuncReshaped = @(x, varargin) objectiveFunc(x, varargin{:});
end

% Trim values of objective function smaller than tolerance in each
% iteration
trimObjectiveFunction = opt.TrimObjectiveFunction;

xInit = xInit(:);
numOfUnknowns = numel(xInit);

temp = struct('NumberOfVariables', numOfUnknowns);

displayLevel = getDisplayLevel( );
if nargin<4
    header = '';
end
tolX = opt.StepTolerance;
tolFun = opt.FunctionTolerance;
maxIter = opt.MaxIterations;
maxFunEvals = opt.MaxFunctionEvaluations;
if isa(maxIter, 'function_handle')
    maxIter = maxIter(temp);
end
if isa(maxFunEvals, 'function_handle')
    maxFunEvals = maxFunEvals(temp);
end

current = ITER_STRUCT;
current.Iter = 0;
current.X = xInit;
current.F = objectiveFuncReshaped(current.X);
sizeOfF = size(current.F);
current.F = current.F(:);
current.Norm = fnNorm(current.F);
current.Step = NaN;

last = ITER_STRUCT;
last.J = 1;

best = ITER_STRUCT;
best.Norm = Inf;

w = warning( );
warning('off', 'MATLAB:nearlySingularMatrix');
warning('off', 'MATLAB:singularMatrix');

exitFlag = solver.ExitFlag.IN_PROGRESS;
fnCount = 1;
iter = 0;
needsPrintHeader = true;
extraJacobUpdate = false;

while true
    %
    % Set jacobUpdate=false in case this is the last iteration, which means
    % no Jacobian update no matter what.
    %

    jacobUpdate = false;

    %
    % Check convergence before calculating current Jacobian
    %

    if current.Norm<=best.Norm
        best = current;
    end
    
    if hasConverged( ) 
        % Convergence reached, exit
        exitFlag = solver.ExitFlag.CONVERGED;
        break
    end
    
    if iter>=maxIter
        % Max iter reached, exit
        exitFlag = solver.ExitFlag.MAX_ITER;
        break
    end
    
    if fnCount>=maxFunEvals
        % Max fun evals reached, exit
        exitFlag = solver.ExitFlag.MAX_FUN_EVALS;
        break
    end

    %
    % Calculate Jacobian for current iteration
    %

    jacobUpdate = iter<=lastJacobUpdate || extraJacobUpdate;
    if jacobUpdate 
        if opt.SpecifyObjectiveGradient
            [current.F, current.J] = objectiveFuncReshaped(current.X);
            fnCount = fnCount + 1;
            current.F = current.F(:);
        else
            [current.J, addCount] = solver.algorithm.finiteDifference( objectiveFuncReshaped, ...
                                                                       current.X, current.F, diffStep, ...
                                                                       jacobPattern, opt.LargeScale );
            fnCount = fnCount + addCount;
        end
    else
        current.J = last.J;
    end

    %
    % NaN of Inf in Jacobian
    %
    if any(~isfinite(current.J(:)))
        % Max fun evals reached, exit
        exitFlag = solver.ExitFlag.NAN_INF_JACOB;
        break
    end

    %
    % Report Current iteration
    % Step size from Current to Next is reported in Next
    %
    
    if displayLevel.Iter
        if mod(iter, displayLevel.Every)==0
            reportIter( );
            fprintf('\n');
        end
    end

    %
    % Make step from Current to Next iteration
    %

    iter = iter + 1;
    next = ITER_STRUCT;
    next.Iter = iter;

    doOptimizeNewtonStepSize = iter<=lastStepSizeOptim;
    if doOptimizeNewtonStepSize
        %
        % Optimize size of Newton step
        % This is can only be invoked when QaD is called and step is Newton
        %

        next.Step = linspace(0, opt.InitStepSize, NUM_OF_OPTIM_STEP_SIZES+1);
        next.Step = next.Step(2:end);
    else
        %
        % Business as usual otherwise
        % Set step size between Current and Next iterations
        %
        % * StepSizeSwitch=0 means step size always reset to default
        % * StepSizeSwitch=1 means reuse step size from previous iteration
        %

        if opt.StepSizeSwitch==0 
            next.Step = DEFAULT_STEP_SIZE;
        else
            next.Step = current.Step;
            if isnan(next.Step)
                next.Step = opt.InitStepSize;
            end
        end
    end

    if isempty(vecOfLambdas)
        makeNewtonStep( );
    else
        makeHybridStep( );
    end

    %
    % Try to deflate or inflate the step size if needed or desirable
    %

    if doTryMakeProgress && next.Norm>current.Norm 
        % Change step until objective function improves; try to deflate
        % first, then try to inflate
        success = tryMakeProgress(deflateStep);
        if ~success
            tryMakeProgress(inflateStep);
        end
    elseif doTryImproveProgress
        % Change step as far as objective function improves; try to
        % inflate first, then try to deflate
        success = tryImproveProgress(inflateStep);
        if ~success
            tryImproveProgress(deflateStep);
        end
    end
    
    %
    % Check progress between Current and Next iteration
    %

    if jacobUpdate
        threshold = current.Norm;
        if next.Norm>threshold
            % No further progress can be made, exit and report current (not
            % next) iteration as the last iteration
            exitFlag = solver.ExitFlag.NO_PROGRESS;
            break
        end
    else
        threshold = 1.5*best.Norm;
        if next.Norm>threshold
            current = best;
            current.Step = 0.5*next.Step;
            current.Iter = iter;
            current.Reverse = true;
            if displayLevel.Iter
                reportReverse( );
            end
            extraJacobUpdate = true;
            continue
        end
    end

    next.MaxXChng = maxChgFunc(next.X, current.X);

    %
    % Move to Next iteration
    %

    extraJacobUpdate = false;
    last = current;
    current = next;
end

warning(w);

if displayLevel.Iter && exitFlag~=solver.ExitFlag.NO_PROGRESS
    if desktopStatus
        fprintf('<strong>');
    end
    reportIter( );
    if desktopStatus
        fprintf('</strong>');
    end
    fprintf('\n');
end

if displayLevel.Final
    reportFinal( );
end

if displayLevel.Any
    fprintf('\n');
end

x = reshape(current.X, sizeOfX);
f = reshape(current.F, sizeOfF);

return


    function makeNewtonStep( )
        % Get and trim current objective function
        F0 = getCurrentObjectiveFunction( );
        lastwarn('');
        next.D = -current.J \ F0;
        if opt.UsePinvIfJacobSingular && ~isempty(lastwarn( ))
            next.D = -pinv(current.J) * F0;
        end
        step = next.Step;
        lenOfStepSize = numel(step);
        X = cell(1, lenOfStepSize);
        F = cell(1, lenOfStepSize);
        N = nan(1, lenOfStepSize);
        for ii = 1 : lenOfStepSize
            X{ii} = current.X + step(ii)*next.D;
            F{ii} = objectiveFuncReshaped(X{ii});
            fnCount = fnCount + 1;
            F{ii} = F{ii}(:);
            N(ii) = fnNorm(F{ii});
        end
        if lenOfStepSize==1
            next.Norm = N;
            pos = 1;
        else
            [next.Norm, pos] = min(N);
        end
        next.X = X{pos};
        next.Step = step(pos);
        next.F = F{pos};
        next.Lambda = 0;
        if lenOfStepSize>1 && displayLevel.Iter
            reportStepSizeOptim( );
        end
    end%


    function makeHybridStep( )
        X0 = current.X;
        J0 = current.J;

        % Get and trim current objective function
        F0 = getCurrentObjectiveFunction( );

        jj = J0.' * J0;
        step = next.Step;
        if issparse(J0)
            maxSingularValue = svds(J0, 1, 'largest');
            minSingularValue = svds(J0, 1, 'smallest');
        else
            sj = svd(J0);
            maxSingularValue = max(sj);
            minSingularValue = sj(end);
        end
        tol = numOfUnknowns * eps(maxSingularValue);
        vecOfLambdas0 = vecOfLambdas;
        if minSingularValue>tol
            vecOfLambdas0 = [0, vecOfLambdas0];
        end
        lenOfLambda0 = numel(vecOfLambdas0);
        scale = tol * eye(numOfUnknowns);
        
        % Optimize lambda
        D = cell(1, lenOfLambda0);
        X = cell(1, lenOfLambda0);
        F = cell(1, lenOfLambda0);
        N = nan(1, lenOfLambda0);
        for ii = 1 : lenOfLambda0
            if vecOfLambdas0(ii)==0
                % Lambda=0; run Newton step
                D{ii} = -J0 \ F0;
            else
                % Lambda>0; run hybrid step
                D{ii} = -( jj + vecOfLambdas0(ii)*scale ) \ J0.' * F0;
            end
            X{ii} = X0 + step*D{ii};
            F{ii} = objectiveFuncReshaped(X{ii});
            fnCount = fnCount + 1;
            F{ii} = F{ii}(:);
            N(ii) = fnNorm(F{ii});
        end
        [next.Norm, pos] = min(N);
        next.Lambda = vecOfLambdas0(pos);
        next.D = D{pos};
        next.X = X{pos};
        next.F = F{pos};
    end%


    %
    % Get and trim current value of objective function
    %
    function F0 = getCurrentObjectiveFunction( )
        F0 = current.F;
        if trimObjectiveFunction
            F0(abs(F0)<=tolFun) = 0;
        end
    end%


    %
    % Try changing the step size until the function improves
    %
    function success = tryMakeProgress(changeStep)
        X0 = current.X;
        N0 = current.Norm;
        step = next.Step;
        D = next.D;
        success = false;
        iterMakeProgress = 0;
        while step>=MIN_STEP && step<=MAX_STEP && iterMakeProgress<MAX_ITER_MAKE_PROGRESS
            step = changeStep*step;
            X = X0 + step*D;
            F = objectiveFuncReshaped(X);
            fnCount = fnCount + 1;
            F = F(:);
            N = fnNorm(F);
            if N<=N0
                next.X = X;
                next.F = F;
                next.Step = step;
                next.Norm = N;
                success = true;
                break
            end
            iterMakeProgress = iterMakeProgress + 1;
        end
    end%


    %
    % Try changing the step size as far as function norm improves
    %
    function success = tryImproveProgress(changeStep)
        X0 = current.X;
        D0 = next.D;
        step = next.Step;
        N0 = next.Norm;
        iterImproveProgress = 0;
        while step>=MIN_STEP && step<=MAX_STEP && iterImproveProgress<MAX_ITER_IMPROVE_PROGRESS
            step = changeStep*step;
            X = X0 + step*D0;
            F = objectiveFuncReshaped(X);
            fnCount = fnCount + 1;
            F = F(:);
            N = fnNorm(F);
            if N>=N0
                break
            end
            iterImproveProgress = iterImproveProgress + 1;
            next.X = X;
            next.F = F;
            next.Norm = N;
            next.Step = step;
        end
        success = iterImproveProgress>0;
    end%


    %
    % Check for function and step convergence
    %
    function flag = hasConverged( )
        flag = all( max(abs(current.F(:)))<=tolFun );
        if current.Iter>0
            flag = flag && all(current.MaxXChng<=tolX);
        end
    end%


    function printHeader( )
        fprintf('\n');
        c1 = sprintf( FORMAT_HEADER, ...
                      'Iter', ...
                      'Fn-Count', ...
                      'Fn-Norm', ...
                      'Lambda', ...
                      'Step-Size', ...
                      'Fn-Norm-Chg', ...
                      'Max-X-Chg', ...
                      'Max-Jacob-Chg ' );
        c2 = sprintf( FORMAT_HEADER, ...
                      '', ...
                      '', ...
                      strFnNorm, ...
                      stepType, ...
                      '', ...
                      '', ...
                      '', ...
                      strJacobNorm );
        disp(c1);
        disp(c2);
        disp( repmat('-', 1, max(length(c1), length(c2))) );
    end%


    function reportIter( )
        if needsPrintHeader
            printHeader( );
            needsPrintHeader = false;
        end
        strJacobUpdate = '';
        if jacobUpdate
            strJacobUpdate = '*';
        end
        fprintf( FORMAT_ITER, ...
                 current.Iter, ...
                 fnCount, ...
                 current.Norm, ...
                 current.Lambda, ...
                 current.Step, ...
                 abs(current.Norm-last.Norm), ...
                 current.MaxXChng, ...
                 maxChgFunc(current.J, last.J), ...
                 strJacobUpdate );
    end%


    function reportReverse( )
        fprintf('Reversing to Iteration %g\nReducing Step Size to %g', best.Iter, current.Step);
        fprintf('\n');
    end%


    function reportStepSizeOptim( )
        fprintf('Optimal Step Size %g', next.Step);
        fprintf('\n');
    end%


    function reportFinal( )
        print(exitFlag, header);
    end%


    function displayLevel = getDisplayLevel( )
        displayLevel.Any = ...
            ~isequal(opt.Display, false) ...
            && ~strcmpi(opt.Display, 'none') ...
            && ~strcmpi(opt.Display, 'off');
        displayLevel.Final = displayLevel.Any;
        displayLevel.Iter = ...
            isequal(opt.Display, true) ...
            || strcmpi(opt.Display, 'iter') ...
            || strcmpi(opt.Display, 'iter*') ...
            || (isnumeric(opt.Display) && opt.Display~=0);
        displayLevel.Every = NaN;
        if isnumeric(opt.Display)
            displayLevel.Every = opt.Display;
        elseif isequal(displayLevel.Iter, true)
            displayLevel.Every = 1;
        end
    end%
end%
