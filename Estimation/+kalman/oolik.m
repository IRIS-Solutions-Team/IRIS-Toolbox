function [objFunc, V, Est, PEst] = oolik(LogDetF, PeFiPe, MtFiM, MtFiPe, NObs, opt)
% oolik  Estimate out-of-lik parameters and sum up log-likelihood function components
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

%#ok<*CTCH>

if ~isfield(opt, 'ObjFunc')
    opt.ObjFunc = 1;
end

%--------------------------------------------------------------------------

sumNumObs = sum(NObs, 2);
sumLogDetF = sum(LogDetF, 2);
sumPeFiPe = sum(PeFiPe, 2);
sumMtFiM = sum(MtFiM, 3);
sumMtFiPe = sum(MtFiPe, 2);
isOutOfLik = ~isempty(sumMtFiM) && ~isempty(sumMtFiPe);

% Estimate user-requested out-of-lik parameters
if isOutOfLik
    L2i = pinv(sumMtFiM);
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

% Put together the requested objective function
if opt.ObjFunc==1
    % Minus log likelihood
    log2Pi = log(2*pi);
    objFunc = (sumNumObs*log2Pi + sumLogDetF + sumPeFiPe) / 2;
else
    % Weighted prediction errors
    objFunc = sumPeFiPe / 2;
end

if ~opt.ReturnObjFuncContribs
    return
end

% 
% Objective Function Components
%
if isOutOfLik
    PeFiPe = PeFiPe - Est.'*MtFiPe;
end
if V~=1
    LogDetF = LogDetF + NObs*log(V);
    PeFiPe = PeFiPe / V;
end
sumObj = objFunc;
if opt.ObjFunc==1
    objFunc = (NObs*log2Pi + LogDetF + PeFiPe) / 2;
else
    objFunc = PeFiPe / 2;
end
objFunc(1) = sumObj;

end%

