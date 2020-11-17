% qnsd  Quasi-Newton-Steepest-Descent algorithm
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [x, f, exitFlag] = qnsd(objectiveFunc, initX, opt, exitFlagHeader)

FORMAT_ITER   = '%6g %8g %13g %6g %13g %13g %13g %13g %13s %9s';
MIN_STEP = 1e-8;
MAX_STEP = 2;
MAX_ITER_IMPROVE_PROGRESS = 40;
MAX_ITER_MAKE_PROGRESS = 40;
DEFAULT_STEP_SIZE = 1;
NUM_OF_OPTIM_STEP_SIZES = 10;

ITER_STRUCT = struct( );
ITER_STRUCT.Iter = NaN;
ITER_STRUCT.X = NaN;
ITER_STRUCT.MaxXChng = NaN;
ITER_STRUCT.F = NaN;
ITER_STRUCT.J = [ ];
ITER_STRUCT.InvJ = [ ];
ITER_STRUCT.Lambda = NaN;
ITER_STRUCT.D = NaN;
ITER_STRUCT.Norm = NaN;
ITER_STRUCT.Step = NaN;
ITER_STRUCT.Reverse = false;
ITER_STRUCT.BoundsReport = "None";

%--------------------------------------------------------------------------

if nargin>=4
    exitFlagHeader = string(exitFlagHeader);
else
    exitFlagHeader = "";
end

if ~isempty(opt.DisplayLevel)
    displayLevel = opt.DisplayLevel;
else
    displayLevel = solver.DisplayLevel(opt.Display);
end

desktopStatus = iris.get('DesktopStatus');
maxChgFunc = @(x, x0) full(max(abs(x(:)-x0(:))));

vecLambdas = opt.Lambda;
vecLambdas(vecLambdas==0) = [ ];

if isa(opt.FunctionNorm, 'function_handle')
    fnNorm = opt.FunctionNorm;
else
    fnNorm = @(x) norm(x, opt.FunctionNorm);
end

lastStepSizeOptim = opt.LastStepSizeOptim;
if ~isempty(vecLambdas)
    % Never optimize Hybrid step size
    lastStepSizeOptim = 0;
end

deflateStep = opt.DeflateStep;
inflateStep = opt.InflateStep;
doTryMakeProgress = ~isequal(deflateStep, false);
doTryImproveProgress = ~isequal(inflateStep, false);
diffStep = opt.FiniteDifferenceStepSize;
lastJacobUpdate = round(opt.LastJacobUpdate);
modJacobUpdate = round(opt.SkipJacobUpdate) + 1;
lastBroydenUpdate = round(opt.LastBroydenUpdate);
useAnalyticalJacob = startsWith(opt.JacobCalculation, "Analytical", "ignoreCase", true);

%
% Prepare bounds
%
bounds = opt.Bounds;
if isempty(bounds) || all(isinf(bounds(:)));
    bounds = [ ];
end

sizeX = size(initX);
if any(sizeX(2:end)>1)
    objectiveFuncReshaped = @(x, varargin) objectiveFunc(reshape(x, sizeX), varargin{:});
else
    objectiveFuncReshaped = @(x, varargin) objectiveFunc(x, varargin{:});
end

% Trim values of objective function smaller than tolerance in each
% iteration
trimObjectiveFunction = opt.TrimObjectiveFunction;

initX = initX(:);
numUnknowns = numel(initX);

temp = struct('NumberOfVariables', numUnknowns);

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
[current.X, current.BoundsReport] = locallyEnforceBounds(initX, bounds);
current.F = objectiveFuncReshaped(current.X);
sizeF = size(current.F);
current.F = current.F(:);
current.Norm = fnNorm(current.F);
current.Step = NaN;
current.InvJ = [ ];

last = ITER_STRUCT;

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

headerInfo = hereCompileHeaderInfo( );


%===========================================================================
while true
    %
    % Set jacobUpdate=false in case this is the last iteration, which means
    % no Jacobian update no matter what.
    %

    jacobUpdate = false;
    jacobUpdateString = "None";

    %
    % Check convergence before calculating current Jacobian
    %

    if ~isfinite(current.Norm)
        exitFlag = solver.ExitFlag.NAN_INF_OBJECTIVE;
        break
    end

    if current.Norm<=best.Norm
        best = current;
    end
    
    if hereVerifyConvergence( ) 
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
    jacobUpdate = (iter<=lastJacobUpdate && mod(iter, modJacobUpdate)==0) || extraJacobUpdate;
    if jacobUpdate 
        if useAnalyticalJacob
            [~, current.J] = objectiveFuncReshaped(current.X, [ ], last.J);
            fnCount = fnCount + 1;
            jacobUpdateString = "Analytical";
        else
            [current.J, addCount] = solver.algorithm.forwardDifference( ...
                objectiveFuncReshaped, current.X, current.F, diffStep, opt.JacobPattern ...
            );
            fnCount = fnCount + addCount;
            jacobUpdateString = "Forward-Diff";
        end
        current.InvJ = [ ];

    elseif iter>0 && iter<=lastBroydenUpdate && ~current.Reverse
        jacobUpdateString = hereUpdateJacobByBroyden( );

    else
        current.J = last.J;
        current.InvJ = last.InvJ;
        % if iter>lastJacobUpdate && isempty(current.InvJ)
            % current.InvJ = inv(current.J);
        % end
        if isempty(current.J) && isempty(current.InvJ)
            current.J = 1;
        end
        jacobUpdateString = "None";
    end

    %
    % NaN of Inf in Jacobian
    %
    if any(isnan(current.J(:)) | isinf(current.J(:)))
        exitFlag = solver.ExitFlag.NAN_INF_JACOB;
        break
    end

    %
    % Report Current iteration
    % Step size from Current to Next is reported in Next
    %
    if displayLevel.Iter
        if mod(iter, displayLevel.Every)==0
            hereReportIter( );
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

    if isempty(vecLambdas)
        hereMakeNewtonStep( );
    else
        hereMakeHybridStep( );
    end

    %
    % Try to deflate or inflate the step size if needed or desirable
    %
    if doTryMakeProgress && next.Norm>current.Norm 
        % Change the step size until objective function improves; try to
        % deflate first, then try to inflate
        success = hereTryMakeProgress(deflateStep);
        if ~success
            hereTryMakeProgress(inflateStep);
        end
    elseif doTryImproveProgress
        % Change the step size as far as objective function improves; try
        % to inflate first, then try to deflate
        success = hereTryImproveProgress(inflateStep);
        if ~success
            hereTryImproveProgress(deflateStep);
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
        if opt.StepSizeSwitch==1
            threshold = 1.5*best.Norm;
            if next.Norm>threshold
                current = best;
                current.Step = 0.5*next.Step;
                current.Iter = iter;
                current.Reverse = true;
                if displayLevel.Iter
                    hereReportReversal( );
                end
                if opt.ForceJacobUpdateWhenReversing
                    extraJacobUpdate = true;
                end
                continue
            end
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
%===========================================================================


% Restore warning messages
warning(w);

if displayLevel.Iter
    if desktopStatus
        fprintf('<strong>');
    end
    hereReportIter( );
    if desktopStatus
        fprintf('</strong>');
    end
    fprintf('\n');
end

print(exitFlag, exitFlagHeader, displayLevel);

x = reshape(current.X, sizeX);
f = reshape(current.F, sizeF);

return


    function headerInfo = hereCompileHeaderInfo( )
        headerInfo.Format = '%6s %8s %13s %6s %13s %13s %13s %13s %13s %9s';

        % Function norm
        if isa(opt.FunctionNorm, 'function_handle')
            strFnNorm = func2str(opt.FunctionNorm);
            strFnNorm = regexprep(strFnNorm, '^@\(.*?\)', '', 'once');
            if length(strFnNorm)>12
                strFnNorm = strFnNorm(1:12);
            end
        else
            strFnNorm = sprintf('norm(x,%g)', opt.FunctionNorm);
        end
        headerInfo.FnNorm = strFnNorm;

        % Step type
        if isempty(vecLambdas)
            headerInfo.StepType = 'Newton';
        else
            headerInfo.StepType = 'Hybrid';
        end

        % Number of equations and unknowns
        headerInfo.NumEquations = numel(current.F);
        headerInfo.NumUnknowns = numUnknowns;
    end%


    function jacobUpdateString = hereUpdateJacobByBroyden( )
        step = current.Step;
        if ~isscalar(step) || isnan(step) || isinf(step)
            jacobUpdateString = "None";
            return
        end

        if ~isfield(last, "InvJ") || isempty(last.InvJ)
            last.InvJ = inv(last.J);
        end
        invJacob = last.InvJ;

        u = invJacob * (current.F - last.F);
        d = current.X - last.X;
        c = reshape(d, 1, [ ]) * reshape(u, [ ], 1);
        invJacob = invJacob + 0.*reshape(d - u, [ ], 1) * reshape(d, 1, [ ]) * invJacob / c;

        current.J = [ ];
        current.InvJ = invJacob;
        jacobUpdateString = "Broyden";
    end%


    function hereMakeNewtonStep( )
        % Get and trim current objective function
        F0 = hereGetCurrentObjectiveFunction( );
        step = next.Step;
        lenStepSize = numel(step);
        lastwarn('');

        if isfield(current, "InvJ") && ~isempty(current.InvJ)
            next.D = -current.InvJ * F0;
        else
            jacob = current.J;
            next.D = -jacob \ F0;
            if ~isempty(lastwarn())
                if opt.PseudoinverseWhenSingular
                    next.D = -pinv(full(jacob)) * F0;
                end
            end
        end

        X = cell(1, lenStepSize);
        F = cell(1, lenStepSize);
        N = nan(1, lenStepSize);
        boundsReport = repmat("", 1, lenStepSize);
        for ii = 1 : lenStepSize
            [X{ii}, boundsReport(ii)] = locallyEnforceBounds(current.X + step(ii)*next.D, bounds);
            F{ii} = objectiveFuncReshaped(X{ii});
            fnCount = fnCount + 1;
            F{ii} = F{ii}(:);
            N(ii) = fnNorm(F{ii});
        end
        if lenStepSize==1
            next.Norm = N;
            pos = 1;
        else
            [next.Norm, pos] = min(N);
        end
        next.X = X{pos};
        next.Step = step(pos);
        next.F = F{pos};
        next.Lambda = 0;
        next.BoundsReport = boundsReport(pos);
        if lenStepSize>1 && displayLevel.Iter
            hereReportStepSizeOptim( );
        end
    end%


    function hereMakeHybridStep( )
        X0 = current.X;
        J0 = current.J;

        % Get and trim current objective function
        F0 = hereGetCurrentObjectiveFunction( );

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
        tol = numUnknowns * eps(maxSingularValue);
        vecLambdas0 = vecLambdas;
        if minSingularValue>tol
            vecLambdas0 = [0, vecLambdas0];
        end
        lenLambda0 = numel(vecLambdas0);
        scale = tol * eye(numUnknowns);
        
        % Optimize lambda
        D = cell(1, lenLambda0);
        X = cell(1, lenLambda0);
        F = cell(1, lenLambda0);
        N = nan(1, lenLambda0);
        boundsReport = repmat("", 1, lenLambda0);
        for ii = 1 : lenLambda0
            if vecLambdas0(ii)==0
                % Lambda=0; run Newton step
                D{ii} = -J0 \ F0;
            else
                % Lambda>0; run hybrid step
                D{ii} = -( jj + vecLambdas0(ii)*scale ) \ J0.' * F0;
            end
            [X{ii}, boundsReport(ii)] = locallyEnforceBounds(X0 + step*D{ii}, bounds);
            F{ii} = objectiveFuncReshaped(X{ii});
            fnCount = fnCount + 1;
            F{ii} = F{ii}(:);
            N(ii) = fnNorm(F{ii});
        end
        [next.Norm, pos] = min(N);
        next.Lambda = vecLambdas0(pos);
        next.D = D{pos};
        next.X = X{pos};
        next.F = F{pos};
        next.BoundsReport = boundsReport(pos);
    end%


    %
    % Get and trim current value of objective function
    %
    function F0 = hereGetCurrentObjectiveFunction( )
        F0 = current.F;
        if trimObjectiveFunction
            F0(abs(F0)<=tolFun) = 0;
        end
    end%


    %
    % Try changing the step size until the function improves
    %
    function success = hereTryMakeProgress(changeStep)
        X0 = current.X;
        N0 = current.Norm;
        step = next.Step;
        D = next.D;
        success = false;
        iterMakeProgress = 0;
        while step>=MIN_STEP && step<=MAX_STEP && iterMakeProgress<MAX_ITER_MAKE_PROGRESS
            step = changeStep*step;
            [X, boundsReport] = locallyEnforceBounds(X0 + step*D, bounds);
            F = objectiveFuncReshaped(X);
            fnCount = fnCount + 1;
            F = F(:);
            N = fnNorm(F);
            if N<=N0
                next.X = X;
                next.F = F;
                next.Step = step;
                next.Norm = N;
                next.BoundsReport = boundsReport;
                success = true;
                break
            end
            iterMakeProgress = iterMakeProgress + 1;
        end
    end%


    %
    % Try changing the step size as far as function norm improves
    %
    function success = hereTryImproveProgress(changeStep)
        X0 = current.X;
        D0 = next.D;
        step = next.Step;
        N0 = next.Norm;
        iterImproveProgress = 0;
        while step>=MIN_STEP && step<=MAX_STEP && iterImproveProgress<MAX_ITER_IMPROVE_PROGRESS
            step = changeStep*step;
            [X, boundsReport] = locallyEnforceBounds(X0 + step*D0, bounds);
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
            next.BoundsReport = boundsReport;
        end
        success = iterImproveProgress>0;
    end%


    %
    % Check for function and step convergence
    %
    function flag = hereVerifyConvergence( )
        flag = all( max(abs(current.F(:)))<=tolFun );
        if current.Iter>0
            flag = flag && all(current.MaxXChng<=tolX);
        end
    end%


    function herePrintHeader( )
        %(
        rows = repmat({''}, 1, 4);
        rows{1} = sprintf( ...
            '--Dimension: [%g %g]' ...
            , headerInfo.NumEquations ...
            , headerInfo.NumUnknowns ...
        );
        rows{2} = sprintf( ...
            headerInfo.Format ...
            , 'Iter' ...
            , 'Fn-Count' ...
            , 'Fn-Norm' ...
            , 'Lambda' ...
            , 'Step-Size' ...
            , 'Fn-Norm-Chg' ...
            , 'Max-X-Chg' ...
            , 'Max-Jacob-Chg' ...
            , 'Jacob-Update' ...
            , 'Bounds' ...
        );
        rows{3} = sprintf( ...
            headerInfo.Format ...
            , '' ...
            , '' ...
            , headerInfo.FnNorm ...
            , headerInfo.StepType ...
            , '' ...
            , '' ...
            , '' ...
            , '' ...
            , '' ...
            , '' ...
        );
        maxLen = max(cellfun(@strlength, rows));
        rows{1} = [rows{1}, repmat('-', 1, maxLen-strlength(rows{1}))];
        rows{4} = repmat('-', 1, maxLen);
        fprintf('\n');
        cellfun(@disp, rows);
        %)
    end%


    function hereReportIter( )
        %(
        if needsPrintHeader
            herePrintHeader( );
            needsPrintHeader = false;
        end
        jacobChange = NaN;
        if ~isempty(current.J) && ~isempty(last.J)
            jacobChange = maxChgFunc(current.J, last.J);
        end
        fprintf( ...
            FORMAT_ITER ...
            , current.Iter ...
            , fnCount ...
            , current.Norm ...
            , current.Lambda ...
            , current.Step ...
            , abs(current.Norm-last.Norm) ...
            , current.MaxXChng ...
            , jacobChange ...
            , jacobUpdateString ...
            , current.BoundsReport ...
        );
        %)
    end%


    function hereReportReversal( )
        fprintf('Reversing to Iteration %g\nReducing Step Size to %g', best.Iter, current.Step);
        fprintf('\n');
    end%


    function hereReportStepSizeOptim( )
        fprintf('Optimal Step Size %g', next.Step);
        fprintf('\n');
    end%
end%

%
% Local Function
%

function [x, report] = locallyEnforceBounds(x, bounds)
    %(
    if isempty(bounds)
        report = "None";
        return
    end
    inxLower = reshape(x, 1, [ ])<bounds(1, :);
    inxUpper = reshape(x, 1, [ ])>bounds(2, :);
    anyLower = any(inxLower);
    anyUpper = any(inxUpper);
    if ~anyLower && ~anyUpper
        report = "Honored";
        return
    end
    x0 = x;
    if anyLower
        x(inxLower) = bounds(1, inxLower);
        report = "Enforced";
        report = sprintf("%g", max(abs(x(inxLower))-abs(x0(inxLower))));
    end
    if anyUpper
        x(inxUpper) = bounds(1, inxUpper);
        report = "Enforced";
    end
    %)
end%

