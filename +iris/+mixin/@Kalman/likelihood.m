% likelihood  Estimate out-of-lik parameters and sum up log-likelihood function components
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [objFunc, V, Est, PEst] = likelihood(logDetF, peFiPe, MtFiM, MtFiPe, numObs, opt)

%#ok<*CTCH>

if ~isfield(opt, 'ObjFunc')
    opt.ObjFunc = 1;
end

%--------------------------------------------------------------------------

sumNumObs = sum(numObs, 2);
sumLogDetF = sum(logDetF, 2);
sumPeFiPe = sum(peFiPe, 2);
sumMtFiM = sum(MtFiM, 3);
sumMtFiPe = sum(MtFiPe, 2);
isOutlik = ~isempty(sumMtFiM) && ~isempty(sumMtFiPe);

% Estimate user-requested out-of-lik parameters and unit-root initials
if isOutlik
    L2i = inv(sumMtFiM);
    Est = L2i * sumMtFiPe;
    PEst = L2i;
    % Correct likelihood for estimated parameters
    sumPeFiPe = sumPeFiPe - Est.'*sumMtFiPe;
else
    Est = zeros(0, 1);
    PEst = zeros(0);
end

% Estimate common variance factor
V = 1;
if opt.Relative && opt.ObjFunc==1
    if sumNumObs > 0
        V = sumPeFiPe / sumNumObs;
        sumLogDetF = sumLogDetF + sumNumObs*log(V);
        sumPeFiPe = sumPeFiPe / V;
    else
        sumPeFiPe = 0;
    end
end

log2Pi = log(2*pi);

if ~opt.ReturnObjFuncContribs
    % Put together the requested objective function
    if opt.ObjFunc==1
        % Minus log likelihood
        objFunc = (sumNumObs*log2Pi + sumLogDetF + sumPeFiPe) / 2;
    else
        % Weighted prediction errors
        objFunc = sumPeFiPe / 2;
    end
else
    % 
    % Objective Function Components
    %
    if isOutlik
        peFiPe = peFiPe - Est.'*MtFiPe;
    end
    if V~=1
        logDetF = logDetF + numObs*log(V);
        peFiPe = peFiPe / V;
    end

    if opt.ObjFunc==1
        objFunc = (numObs*log2Pi + logDetF + peFiPe) / 2;
    else
        objFunc = peFiPe / 2;
    end
end

end%

