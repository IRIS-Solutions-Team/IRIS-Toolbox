function pp = myevalpprior(x, pri)

pp = 0;
for i = find(pri.IxPrior)
    if isa(pri.FnPrior{i}, 'distribution.Abstract')
        ithPriorValue = pri.FnPrior{i}.logPdf(x(i));
    elseif isa(pri.FnPrior{i}, 'function_handle')
        ithPriorValue = pri.FnPrior{i}(x(i));
    else
        ithPriorValue = NaN;
    end
    pp = pp + ithPriorValue;
    if ~isfinite(pp) || length(pp) ~= 1
        pp = -Inf;
        break
    end
end
pp = -pp;

end
