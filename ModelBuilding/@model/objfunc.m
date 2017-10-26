function [obj, lik, paramPriorsEval, systemPriorsMinusLogDensity] = objfunc(x, this, data, pri, estOpt, likOpt)
% objfunc  Evaluate minus log posterior.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
    
%--------------------------------------------------------------------------

obj = 0; % Minus log posterior.
lik = 0; % Minus log data likelihood.
paramPriorsEval = 0; % Minus log parameter prior.
systemPriorsMinusLogDensity = 0; % Minus log system prior.

isDataLik = estOpt.EvalLik;
isParamPriors = estOpt.EvalPPrior && any(pri.IxPrior);
isSystemPriors = estOpt.EvalSPrior && ~isempty(pri.SystemPriors);

% Evaluate parameter priors; they return minus log density.
if isParamPriors
    paramPriorsEval = shared.Estimation.evalPrior(x, pri);
    obj = obj + paramPriorsEval;
end

% Update model with new parameter values; do this before evaluating the
% system priors.
if isDataLik || isSystemPriors
    isThrowErr = strcmpi(estOpt.NoSolution, 'error');
    [this,UpdateOk] = update(this, x, pri, 1, estOpt, isThrowErr);
    if ~UpdateOk
        obj = Inf;
    end
end

% Evaluate system priors.
if isfinite(obj) && isSystemPriors
    % Function systempriors/eval returns minus log density.
    systemPriorsMinusLogDensity = eval(pri.SystemPriors, this);
    obj = obj + systemPriorsMinusLogDensity;
end

% Evaluate data likelihood.
if isfinite(obj) && isDataLik
    % Evaluate minus log likelihood; no data output is required.
    lik = likOpt.minusLogLikFunc(this, data, [ ], likOpt);
    % Sum up minus log priors and minus log likelihood.
    obj = obj + lik;
end

isValid = isnumeric(obj) && length(obj)==1 ...
    && isfinite(obj) && imag(obj)==0;
if ~isValid
    if isnumeric(estOpt.NoSolution)
        penalty = estOpt.NoSolution;
    else
        penalty = this.OBJ_FUNC_PENALTY;
    end
    obj = penalty;
end

% Make sure Obj is a double, otherwise Optim Tbx will complain.
obj = double(obj);

end
