function [Obj, V, Est, PEst] = oolik(LogDetF, PeFiPe, MtFiM, MtFiPe, NObs, Opt)
% oolik  Estimate out-of-lik parameters and sum up log-likelihood function components
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%#ok<*CTCH>

try
    Opt.ObjFunc;
catch
    Opt.ObjFunc = 1;
end

%--------------------------------------------------------------------------

sumNObs = sum(NObs, 2);
sumLogDetF = sum(LogDetF, 2);
sumPeFiPe = sum(PeFiPe, 2);
sumMtFiM = sum(MtFiM, 3);
sumMtFiPe = sum(MtFiPe, 2);
isOutOfLik = ~isempty(sumMtFiM) && ~isempty(sumMtFiPe);

% Estimate user-requested out-of-lik parameters.
if isOutOfLik
    L2i = pinv(sumMtFiM);
    Est = L2i * sumMtFiPe;
    PEst = L2i;
    % Correct likelihood for estimated parameters.
    sumPeFiPe = sumPeFiPe - Est.'*sumMtFiPe;
else
    Est = zeros(0, 1);
    PEst = zeros(0);
end

% Estimate common variance factor.
V = 1;
if Opt.Relative && Opt.ObjFunc==1
    if sumNObs > 0
        V = sumPeFiPe / sumNObs;
        sumLogDetF = sumLogDetF + sumNObs*log(V);
        sumPeFiPe = sumPeFiPe / V;
    else
        sumPeFiPe = 0;
    end
end

% Put together the requested objective function.
if Opt.ObjFunc==1
    % Minus log likelihood.
    log2Pi = log(2*pi);
    Obj = (sumNObs*log2Pi + sumLogDetF + sumPeFiPe) / 2;
else
    % Weighted prediction errors.
    Obj = sumPeFiPe / 2;
end

if ~Opt.objdecomp
    return
end

% Objective function factors (components).
if isOutOfLik
    PeFiPe = PeFiPe - Est.'*MtFiPe;
end
if V~=1
    LogDetF = LogDetF + NObs*log(V);
    PeFiPe = PeFiPe / V;
end
sumObj = Obj;
if Opt.ObjFunc==1
    Obj = (NObs*log2Pi + LogDetF + PeFiPe) / 2;
else
    Obj = PeFiPe / 2;
end
Obj(1) = sumObj;

end%

