function [hessian, propCov, validDiff, infoFromLik]  = diffObj(this, data, pStar, hessian, ixBHit, itr, estOpt, likOpt)
% diffObj  Contributions of objective function components to Hessian and proposal covariance
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

numParameters = length(itr.LsParam);
indexDiagonal = logical(eye(numParameters));

% Diagonal elements of the components of the total Hessian.
diffTotal = zeros(1, numParameters);
diffLik = zeros(1, numParameters);
diffParamPrior = zeros(1, numParameters);
diffSystemPrior = zeros(1, numParameters);
validDiff = true(1, numParameters);
infoFromLik = nan(1, numParameters);

% Differentiation step size.
h = eps( )^(1/4) * max(abs(pStar), 1);

for i = 1 : numParameters
    x0 = pStar;
    if ixBHit(i)==-1
        % Lower bound hit; move the centre point up.
        x0(i) = x0(i) + 1.5*h(i);
    elseif ixBHit(i)==1
        % Upper bound hit; move the centre point down.
        x0(i) = x0(i) - 1.5*h(i);
    end
    xp = x0;
    xm = x0;
    xp(i) = x0(i) + h(i);
    xm(i) = x0(i) - h(i);
    [obj0, l0, p0, s0] = objfunc(x0, this, data, itr, estOpt, likOpt);
    [objp, lp, pp, sp] = objfunc(xp, this, data, itr, estOpt, likOpt);
    [objm, lm, pm, sm] = objfunc(xm, this, data, itr, estOpt, likOpt);
    h2 = h(i)^2;
    
    % Diff total objective function.
    ithDiffObj = (objp - 2*obj0 + objm) / h2;
    if ithDiffObj<=0 || ~isfinite(ithDiffObj)
        sgm = 4*max(abs(x0(i)), 1);
        ithDiffObj = 1/sgm^2;
        validDiff(i) = false;
    end
    diffTotal(i) = ithDiffObj;
    
    % Diff data likelihood.
    if estOpt.EvalLik
        diffLik(i) = (lp - 2*l0 + lm) / h2;
    end

    % Proportion of information from data.
    infoFromLik(i) = diffLik(i) / diffTotal(i);
    
    % Diff parameter priors.
    if estOpt.EvalPPrior
        d = (pp - 2*p0 + pm) / h2;
        if ~isempty(itr.FnPrior{i}) && isa(itr.FnPrior{i}, 'function_handle')
            if isa(itr.FnPrior{i}, 'distribution.Distribution')
                d = -itr.FnPrior{i}.info(x0(i));
            elseif isa(itr.FnPrior{i}, 'function_handle')
                try %#ok<TRYNC>
                    d = -itr.FnPrior{i}(x0(i), 'info');
                end
            end
        end
        diffParamPrior(i) = d;
    end
    
    % Diff system priors.
    if estOpt.EvalSPrior
        diffSystemPrior(i) = (sp - 2*s0 + sm) / h2;
    end
end

if isempty(hessian{1})
    hessian{1} = nan(numParameters);
    hessian{1}(indexDiagonal) = diffTotal;
end

if estOpt.EvalPPrior
    % Parameter priors are independent, the off-diagonal elements can be set to
    % zero.
    hessian{2} = diag(diffParamPrior);
else
    hessian{2} = zeros(numParameters);
end

if estOpt.EvalSPrior
    hessian{3} = nan(numParameters);
    hessian{3}(indexDiagonal) = diffSystemPrior;
else
    hessian{3} = zeros(numParameters);
end

% Initial proposal covariance matrix is the diagonal of the Hessian.
propCov = diag(1./diffTotal);

infoFromLik(infoFromLik<0 | ~isfinite(infoFromLik)) = NaN;

end
