function [propCov, hess] ...
    = diffPrior(this, data, pStar, hess, ixBHit, itr, estOpt, likOpt)
% diffPrior  Contributions of priors to Hessian and proposal covariance.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

np = length(itr.LsParam);
diagInx = eye(np)==1;

% Diagonal elements of the varous componenets of the Hessian.
diffObj = zeros(1, np);
diffLik = zeros(1, np);
diffParamPrior = zeros(1, np);
diffSystemPrior = zeros(1, np);

% Differentiation step size.
h = eps( )^(1/3) * max(abs(pStar),1);

for ip = 1 : np
    x0 = pStar;
    if ixBHit(ip)==-1
        % Lower bound hit; move the centre point up.
        x0(ip) = x0(ip) + h(ip);
    elseif ixBHit(ip)==1
        % Upper bound hit; move the centre point down.
        x0(ip) = x0(ip) - h(ip);
    end
    xp = x0;
    xm = x0;
    xp(ip) = x0(ip) + h(ip);
    xm(ip) = x0(ip) - h(ip);
    [obj0, l0, p0, s0] = objfunc(x0, this, data, itr, estOpt, likOpt);
    [objp, lp, pp, sp] = objfunc(xp, this, data, itr, estOpt, likOpt);
    [objm, lm, pm, sm] = objfunc(xm, this, data, itr, estOpt, likOpt);
    h2 = h(ip)^2;
    
    % Diff total objective function.
    iDiffObj = (objp - 2*obj0 + objm) / h2;
    if iDiffObj<=0 || ~isfinite(iDiffObj)
        sgm = 4*max(abs(x0(ip)),1);
        iDiffObj = 1/sgm^2;
    end
    diffObj(ip) = iDiffObj;
    
    % Diff data likelihood.
    if estOpt.EvalLik
        diffLik(ip) = (lp - 2*l0 + lm) / h2;
    end
    
    % Diff parameter priors.
    if estOpt.EvalPPrior
        d = (pp - 2*p0 + pm) / h2;
        if ~isempty(itr.FnPrior{ip}) && isfunc(itr.FnPrior{ip})
            try %#ok<TRYNC>
                d = -itr.FnPrior{ip}(x0(ip), 'info');
            end
        end
        diffParamPrior(ip) = d;
    end
    
    % Diff system priors.
    if estOpt.EvalSPrior
        diffSystemPrior(ip) = (sp - 2*s0 + sm) / h2;
    end
    
end

if isempty(hess{1})
    hess{1} = nan(np);
    hess{1}(diagInx) = diffObj;
end

if estOpt.EvalPPrior
    % Parameter priors are independent, the off-diagonal elements can be set to
    % zero.
    hess{2} = diag(diffParamPrior);
else
    hess{2} = zeros(np);
end

if estOpt.EvalSPrior
    hess{3} = nan(np);
    hess{3}(diagInx) = diffSystemPrior;
else
    hess{3} = zeros(np);
end

% Initial proposal covariance matrix is the diagonal of the Hessian.
propCov = diag(1./diffObj);

end
