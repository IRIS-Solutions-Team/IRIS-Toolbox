function pp = myevalpprior(x, pri)

pp = 0;
for i = find(pri.IxPrior)
    pp = pp + pri.FnPrior{i}(x(i));
    if ~isfinite(pp) || length(pp) ~= 1
        pp = -Inf;
        break
    end
end
pp = -pp;

end
