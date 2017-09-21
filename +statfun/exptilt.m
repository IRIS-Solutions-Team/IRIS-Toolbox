function [w, gamma] = exptilt(data, g)

if ~iscell(g)
    g = { g };
end

ng = numel(g);
h = [ ];
for i = 1 : ng
    x = feval(g{i}, data);
    h = [h; x];
end
nCon = size(h, 1);
nObs = size(h, 2);

obj = @(gamma) sum(exp(gamma*h), 2);
gamma0 = zeros(1, nCon);
gamma = fminunc(obj, gamma0);

w = exp(gamma*h);
w = w/sum(w, 2) * nObs;

end

