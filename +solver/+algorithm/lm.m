function [x, numericExitFlag] = lm(fnObjective, xInit, opt, varargin)

FORMAT_HEADER = '%6s %8s %13s %6s %13s %13s %13s';
FORMAT_ITER   = '%6g %8g %13g %6g %13g %13g %13g';
FN_NORM = opt.FunctionNorm;
VEC_LAMBDA = [0.1, 1, 10, 100]; %, 500, 1000];
STEP_DOWN = opt.StepDown;
STEP_UP = opt.StepUp;
MIN_STEP = 1e-8;
MAX_STEP = 2;

isStepDown = ~isequal(STEP_DOWN, false);
isStepUp = ~isequal(STEP_UP, false);

xInit = xInit(:);
nx = numel(xInit);

temp = struct( ...
    'NumberOfVariables', nx ...
    );

displayLevel = getDisplayLevel( );
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

x = xInit;
lmb = NaN;
step = NaN;
normFn0 = NaN;
iter = 0;
fnCount = 0;
x0 = xInit;

if displayLevel.Iter
    displayHeader( );
end

w = warning( );
warning('off', 'MATLAB:nearlySingularMatrix');

while true
    [f, j] = fnObjective(x, varargin{:});
    fnCount = fnCount + 1;
    normFn = FN_NORM(f);
    
    if hasConverged( ) 
        % Convergence.
        exitFlag = solver.ExitFlag.CONVERGED;
        break
    end
    
    if iter>maxIter
        % Max iter reached.
        exitFlag = solver.ExitFlag.MAX_ITER;
        break
    end
    
    if fnCount>maxFunEvals
        % Max fun evals reached.
        exitFlag = solver.ExitFlag.MAX_FUN_EVALS;
        break
    end
    
   
    if displayLevel.Iter
        displayIter( );
        fprintf('\n');
    end
    f = f(:);
    x0 = x;
    f0 = f;
    normFn0 = FN_NORM(f0);
    jj = j.'*j;
    sj = svd(j);
    tol = max(size(j)) * eps(max(sj));
    vecLmb = VEC_LAMBDA;
    if sj(end)>tol
        vecLmb = [0, vecLmb]; %#ok<AGROW>
    end
    nlmb0 = numel(vecLmb);
    scale = tol * eye(nx);
    
    % Optimize lambda.
    step = 1;
    dd = cell(1, nlmb0);
    nn = nan(1, nlmb0);
    ff = cell(1, nlmb0);
    for i = 1 : nlmb0
        dd{i} = -( jj + vecLmb(i)*scale ) \ j.' * f;
        c = x + step*dd{i};
        ff{i} = fnObjective(c);
        fnCount = fnCount + 1;
        nn(i) = FN_NORM(ff{i});
    end
    [~, pos] = min(nn);
    lmb = vecLmb(pos);
    f = ff{i};
    d = dd{i};
    
    normFn = FN_NORM(f);
    q = 0;
    if normFn>normFn0 && isStepDown
        % Shrink step until objective function improves.
        stepDown( );
    elseif isStepUp
        % Inflate step as far as objective function improves.
        stepUp( );
    end
    
    if normFn>normFn0
        % No further progress can be made.
        exitFlag = solver.ExitFlag.NO_PROGRESS;
        break
    end

    x = x + step*d;
    iter = iter + 1;
end

warning(w);

if displayLevel.Iter
    fprintf('<strong>');
    displayIter( );
    fprintf('</strong>');
    fprintf('\n');
end
if displayLevel.Final
    displayFinal( );
end
if displayLevel.Any
    fprintf('\n');
end
numericExitFlag = double(exitFlag);

return




    function stepDown( )
        % Shrink step until objective function improves.
        while normFn>normFn0 && step>MIN_STEP
            step = STEP_DOWN*step;
            c = x + step*d;
            f = fnObjective(c);
            fnCount = fnCount + 1;
            q = q + 1;
            normFn = FN_NORM(f);
        end
    end




    function stepUp( )
        % Inflate step as far as objective function improves.
        while step<MAX_STEP
            c = x + STEP_UP*step*d;
            f = fnObjective(c);
            fnCount = fnCount + 1;
            q = q + 1;
            normFn1 = FN_NORM(f);
            if normFn1>=normFn || q>=40
                break
            end
            normFn = normFn1;
            step = STEP_UP*step;
        end
    end        




    function flag = hasConverged( )
        flag = all( maxabs(f)<=tolFun );
        if iter>0
            flag = flag && all( maxabs(x-x0)<=tolX );
        end
    end




    function displayHeader( )
        fprintf('\n');
        c = sprintf( ...
            FORMAT_HEADER, ...
            'Iter', ...
            'Fn-Count', ...
            'Fn-Norm', ...
            'Lambda', ...
            'Step-Size', ...
            'Fn-Norm-Chg', ...
            'Max-X-Chg' ...
            );
        disp(c);
        disp( repmat('-', 1, length(c)) );
    end




    function displayIter( )
        fprintf( ...
            FORMAT_ITER, ...
            iter, ...
            fnCount, ...
            FN_NORM(f), ...
            lmb, ...
            step, ...
            normFn-normFn0, ...
            maxabs(x-x0) ...
            );
    end




    function displayFinal( )
        print(exitFlag);
    end




    function displayLevel = getDisplayLevel( )
        displayLevel.Any = ...
            ~isequal(opt.Display, false) ...
            && ~isequal(opt.Display, 'none') ...
            && ~isequal(opt.Display, 'off');
        displayLevel.Final = displayLevel.Any;
        displayLevel.Iter = ...
            isequal(opt.Display, true) ...
            || strcmpi(opt.Display, 'iter');
    end
end
