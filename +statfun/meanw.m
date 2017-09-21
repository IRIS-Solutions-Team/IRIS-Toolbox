function [m, dim] = meanw(x, w, dim)

try, w; catch, w = [ ]; end
try, dim; catch, dim = 2; end

%--------------------------------------------------------------------------

if ~isempty(w) && all(w(1)==w)
    w = [ ];
else
    w = w(:);
end

[x, redim] = statfun.redim(x, dim, 2);

if ~isempty(w)
    w = w / sum(w);
    m = sum(x .* w, 1, 'omitnan');
else
    m = mean(x, 1, 'omitnan');
end

m = statfun.redim(m, redim);

end
