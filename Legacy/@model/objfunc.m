% objfunc  Evaluate minus log posterior
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team
    
function ...
    [mldPosterior, mldData, mldIndiePriors, mldSystemPriors, mldSystemPriorsBreakdown] ...
    = objfunc(x, this, data, posterior, estOpt, likOpt)

numSystemPriors = 0;
if ~isempty(posterior) && ~isempty(posterior.SystemPriors)
    numSystemPriors = posterior.SystemPriors.NumSystemPriors;
end
isSystemPriors = posterior.EvalSystemPriors>0 && numSystemPriors>0;

mldPosterior = 0; % Minus log density of posterior
mldData = 0; % Minus log data likelihood
mldIndiePriors = 0; % Minus log density of individual independent priors
mldSystemPriors = 0; % Minus log density of system priors
mldSystemPriorsBreakdown = nan(1, numSystemPriors); % Breakdown of mld of system priors

% Check lower and upper bounds
if posterior.HonorBounds
    if any(x(:)<posterior.LowerBounds(:)) || any(x(:)>posterior.UpperBounds(:))
        mldPosterior = Inf;
    end
end


%
% Evaluate parameter priors; they return minus log density
%
if isfinite(mldPosterior)
    if posterior.EvalIndiePriors && any(posterior.IndexPriors)
        mldIndiePriors = evalIndiePriors(posterior, x);
        mldPosterior = mldPosterior + posterior.EvalIndiePriors * mldIndiePriors;
    end
end


%
% Update model with new parameter values; do this before evaluating the
% system priors
%
if isfinite(mldPosterior)
    if posterior.EvalDataLik>0 || isSystemPriors
        variantRequested = 1;
        [this, UpdateOk] = update(this, x, variantRequested);
        if ~UpdateOk
            mldPosterior = Inf;
        end
    end
end


%
% Evaluate system priors
%
if isfinite(mldPosterior) && isSystemPriors
    % Function systempriors/eval returns minus log density
    [mldSystemPriors, mldSystemPriorsBreakdown] = eval(posterior.SystemPriors, this);
    mldPosterior = mldPosterior + posterior.EvalSystemPriors * mldSystemPriors;
end


%
% Evaluate data likelihood
%
if isfinite(mldPosterior) && posterior.EvalDataLik>0
    % Evaluate minus log likelihood; request no data output
    argin = struct( ...
        'FilterRange', likOpt.FilterRange, ... 
        'InputData', data, ...
        'OutputData', [], ...
        'InternalAssignFunc', [], ...
        'Options', likOpt ...
    );
    mldData = likOpt.minusLogLikFunc(this, argin);

    % Sum up minus log priors and minus log likelihood
    mldPosterior = mldPosterior + posterior.EvalDataLik * mldData;
end

isValid = isnumeric(mldPosterior) && length(mldPosterior)==1 ...
    && isfinite(mldPosterior) && imag(mldPosterior)==0;

if ~isValid
    if isnumeric(this.Update.NoSolution)
        penalty = this.Update.NoSolution;
    else
        penalty = this.OBJ_FUNC_PENALTY;
    end
    mldPosterior = penalty;
end

% Make sure the value of the objective function is a double, otherwise
% Optim Tbx complains
mldPosterior = double(mldPosterior);

end%

