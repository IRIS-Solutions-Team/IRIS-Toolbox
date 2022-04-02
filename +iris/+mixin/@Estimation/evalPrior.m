function mldParamPriors = myevalpprior(x, pri)

paramPriorsLogDensity = 0;
for i = find(pri.IxPrior)
    if isa(pri.FnPrior{i}, 'distribution.Distribution')
        ithPriorLogDensity = pri.FnPrior{i}.logPdf(x(i));
    elseif isa(pri.FnPrior{i}, 'function_handle')
        ithPriorLogDensity = pri.FnPrior{i}(x(i));
    else
        ithPriorLogDensity = NaN;
    end
    paramPriorsLogDensity = paramPriorsLogDensity + ithPriorLogDensity;
    if ~isfinite(paramPriorsLogDensity) || length(paramPriorsLogDensity)~=1
        paramPriorsLogDensity = -Inf;
        break
    end
end
mldParamPriors = -paramPriorsLogDensity;

end
