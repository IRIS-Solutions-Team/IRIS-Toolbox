function [mldPosterior, mldData, mldParamPriors, mldSystemPriors] = objfunc(x, this, data, posterior, estOpt, likOpt)
% objfunc  Evaluate minus log posterior
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team
    
%--------------------------------------------------------------------------

mldPosterior = 0; % Minus log density of posterior
mldData = 0; % Minus log data likelihood
mldParamPriors = 0; % Minus log density of parameter priors
mldSystemPriors = 0; % Minus log density of system priors

isSystemPriors = posterior.EvaluateSystemPriors && ~isempty(posterior.SystemPriors);

% Check lower and upper bounds
if any(x(:)<posterior.LowerBounds(:)) || any(x(:)>posterior.UpperBounds(:))
    mldPosterior = Inf;
end

% Evaluate parameter priors; they return minus log density
if isfinite(mldPosterior)
    if posterior.EvaluateParamPriors && any(posterior.IndexPriors)
        mldParamPriors = evalParamPriors(posterior, x);
        mldPosterior = mldPosterior + mldParamPriors;
    end
end

% Update model with new parameter values; do this before evaluating the
% system priors
if isfinite(mldPosterior)
    if posterior.EvaluateData || isSystemPriors
        variantRequested = 1;
        [this, UpdateOk] = update(this, x, variantRequested);
        if ~UpdateOk
            mldPosterior = Inf;
        end
    end
end

% Evaluate system priors
if isfinite(mldPosterior) && isSystemPriors
    % Function systempriors/eval returns minus log density.
    mldSystemPriors = eval(posterior.SystemPriors, this);
    mldPosterior = mldPosterior + mldSystemPriors;
end

% Evaluate data likelihood
if isfinite(mldPosterior) && posterior.EvaluateData
    % Evaluate minus log likelihood; no data output is required.
    mldData = likOpt.minusLogLikFunc(this, data, [ ], [ ], likOpt);
    % Sum up minus log priors and minus log likelihood.
    mldPosterior = mldPosterior + mldData;
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

% Make sure Obj is a double, otherwise Optim Tbx will complain
mldPosterior = double(mldPosterior);

end%

