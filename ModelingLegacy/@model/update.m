% update  Update parameters, sstate, solve, and refresh
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [this, success] = update(this, p, variantRequested)

if nargin<3
    variantRequested = 1;
end

update = this.Update;
posValues = update.PosOfValues;
posStdCorr = update.PosOfStdCorr;

inxValues = ~isnan(posValues);
posValues = posValues(inxValues);
inxStdCorr = ~isnan(posStdCorr);
posStdCorr = posStdCorr(inxStdCorr);

% Reset parameters and stdcorrs
this.Variant.Values(:, :, variantRequested) = update.Values;
this.Variant.StdCorr(:, :, variantRequested) = update.StdCorr;

% Update regular parameters and run refresh if needed
needsRefresh = any(this.Link);
beenRefreshed = false;
if any(inxValues)
    this.Variant.Values(:, posValues, variantRequested) = p(inxValues);
end


% Update stdCorr
if any(inxStdCorr)
    this.Variant.StdCorr(:, posStdCorr, variantRequested) = p(inxStdCorr);
end


% Refresh dynamic links; the links can refer/define std devs and
% cross-corrs
if needsRefresh
    this = refresh(this, variantRequested);
    beenRefreshed = true;
end


% If only stds or corrs have been changed, no values have been refreshed,
% return immediately since there is no need to recalculate steady state or
% solution
if ~any(inxValues) && ~beenRefreshed
    success = true;
    return
end


if this.IsLinear
    %
    % Linear Models
    %
    if update.Solve.Run
        [this, solveInfo] = solveFirstOrder(this, variantRequested, update.Solve);
    else
        solveInfo = struct();
        solveInfo.ExitFlag = 1;
    end
    if update.Steady.Run
        this = steadyLinear(this, update.Steady, variantRequested);
        if needsRefresh
            this = refresh(this, variantRequested);
        end
    end
    steadySuccess = true;
    checkSteadySuccess = true;
    listSteadyErrors = { };

else
    %
    % Nonlinear Models
    %
    steadySuccess = true;
    listSteadyErrors = { };
    checkSteadySuccess = true;
    if update.Steady.Run
        [this, steadySuccess] = steadyNonlinear(this, update.Steady, variantRequested);
        if needsRefresh
            this = refresh(this, variantRequested);
        end
    end
    % Run checkSteady only if running steady()
    if update.Steady.Run && update.CheckSteady.Run
        [~, ~, ~, listSteadyErrors] = implementCheckSteady(this, variantRequested, update.CheckSteady);
        listSteadyErrors = listSteadyErrors{1};
        checkSteadySuccess = isempty(listSteadyErrors);
    end
    if steadySuccess && checkSteadySuccess && update.Solve.Run
        [this, solveInfo] = solveFirstOrder(this, variantRequested, update.Solve);
    else
        solveInfo = struct();
        solveInfo.ExitFlag = 1;
    end
end

success = solveInfo.ExitFlag==1 && steadySuccess && checkSteadySuccess;
if success
    return
end

if startsWith(update.NoSolution, "error", "ignoreCase", true)
    % Throw error, give access to the failed model object and terminate
    m = this(variantRequested);
    model.failed(m, steadySuccess, checkSteadySuccess, listSteadyErrors, solveInfo);
end

end%

