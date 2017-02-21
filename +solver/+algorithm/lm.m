function [x, numericExitFlag] = lm(fnObjective, xInit, opt, varargin)

FORMAT_HEADER = '%6s %8s %13s %6s %13s %13s %13s';
FORMAT_ITER   = '%6g %8g %13g %6g %13g %13g %13g';
MIN_STEP = 1e-8;
MAX_STEP = 2;

%--------------------------------------------------------------------------

vecLmb = opt.Lambda;
if isempty(vecLmb)
    strStepType = 'Newton';
else
    strStepType = 'Hybrid';
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
stepDown = opt.StepDown;
stepUp = opt.StepUp;
isStepDown = ~isequal(stepDown, false);
isStepUp = ~isequal(stepUp, false);

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
n0 = NaN;
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
    f = f(:);
    n = fnNorm(f);
    
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
    x0 = x;
    f0 = f;
    n0 = n;

    step = 1;
    if isempty(vecLmb)
        [d, n] = makeNewtonStep( );
    else
        [d, n] = makeHybridStep( );
    end

    q = 0;
    if n>n0 && isStepDown
        % Shrink step until objective function improves.
        makeStepDown( );
    elseif isStepUp
        % Inflate step as far as objective function improves.
        makeStepUp( );
    end
    
    if n>n0
        % No further progress can be made.
        exitFlag = solver.ExitFlag.NO_PROGRESS;
        break
    end

    x = x + step*d;
    iter = iter + 1;
end

warning(w);

if displayLevel.Iter
    try
        jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
        isDesktop = ~isempty(jDesktop.getClient('Command Window'));
    catch
        isDesktop = false;
    end
    if isDesktop
        fprintf('<strong>');
    end
    displayIter( );
    if isDesktop
        fprintf('</strong>');
    end
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




    function [d, n] = makeNewtonStep( )
        lmb = 0;
        d = -j \ f;
        c = x + step*d;
        f = fnObjective(c, varargin{:});
        n = fnNorm(f);
    end




    function [d, n] = makeHybridStep( )
        jj = j.'*j;
        sj = svd(j);
        tol = max(size(j)) * eps(max(sj));
        vecLmb0 = vecLmb;
        if sj(end)>tol
            vecLmb0 = [0, vecLmb0]; %#ok<AGROW>
        end
        nlmb0 = numel(vecLmb0);
        scale = tol * eye(nx);
        
        % Optimize lambda.
        dd = cell(1, nlmb0);
        nn = nan(1, nlmb0);
        ff = cell(1, nlmb0);
        for i = 1 : nlmb0
            dd{i} = -( jj + vecLmb0(i)*scale ) \ j.' * f;
            c = x + step*dd{i};
            ff{i} = fnObjective(c, varargin{:});
            fnCount = fnCount + 1;
            nn(i) = fnNorm(ff{i});
        end
        [~, pos] = min(nn);
        lmb = vecLmb0(pos);
        d = dd{i};
        f = ff{i};
        n = nn(i);
    end 



    function makeStepDown( )
        % Shrink step until objective function improves.
        while n>n0 && step>MIN_STEP
            step = stepDown*step;
            c = x + step*d;
            f = fnObjective(c, varargin{:});
            fnCount = fnCount + 1;
            q = q + 1;
            n = fnNorm(f);
        end
    end




    function makeStepUp( )
        % Inflate step as far as objective function improves.
        while step<MAX_STEP
            c = x + stepUp*step*d;
            f = fnObjective(c, varargin{:});
            fnCount = fnCount + 1;
            q = q + 1;
            n1 = fnNorm(f);
            if n1>=n || q>=40
                break
            end
            n = n1;
            step = stepUp*step;
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
        c1 = sprintf( ...
            FORMAT_HEADER, ...
            'Iter', ...
            'Fn-Count', ...
            'Fn-Norm', ...
            'Lambda', ...
            'Step-Size', ...
            'Fn-Norm-Chg', ...
            'Max-X-Chg' ...
            );
        c2 = sprintf( ...
            FORMAT_HEADER, ...
            '', ...
            '', ...
            strFnNorm, ...
            strStepType, ...
            '', ...
            '', ...
            '' ...
            );
        disp(c1);
        disp(c2);
        disp( repmat('-', 1, max(length(c1), length(c2))) );
    end




    function displayIter( )
        fprintf( ...
            FORMAT_ITER, ...
            iter, ...
            fnCount, ...
            n, ...
            lmb, ...
            step, ...
            n-n0, ...
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
