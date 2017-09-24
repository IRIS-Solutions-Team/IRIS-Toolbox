function [obj, lik, pp, sp] = objfunc(x, this, data, pri, estOpt, likOpt)
% objfunc  Evaluate minus log posterior.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
    
%--------------------------------------------------------------------------

obj = 0; % Minus log posterior.
lik = 0; % Minus log data likelihood.
pp = 0; % Minus log parameter prior.
sp = 0; % Minus log system prior.

isLik = estOpt.EvalLik;
isPPrior = estOpt.EvalPPrior && any(pri.IxPrior);
isSPrior = estOpt.EvalSPrior && ~isempty(pri.SystemPrior);

% Evaluate parameter priors.
if isPPrior
    pp = shared.Estimation.evalPrior(x, pri);
    obj = obj + pp;
end

% Update model with new parameter values; do this before evaluating the
% system priors.
if isLik || isSPrior
    isThrowErr = strcmpi(estOpt.NoSolution, 'error');
    [this,UpdateOk] = update(this, x, pri, 1, estOpt, isThrowErr);
    if ~UpdateOk
        obj = Inf;
    end
end

% Evaluate system priors.
if isfinite(obj) && isSPrior
    % Function systempriors/eval returns minus log density.
    sp = eval(pri.SystemPrior, this);
    obj = obj + sp;
end

% Evaluate data likelihood.
if isfinite(obj) && isLik
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
