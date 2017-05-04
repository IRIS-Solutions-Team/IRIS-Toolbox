function [W, dW] = evalDtrends(this, posPout, G, alt)
% evalDtrends  Evaluate dtrend coefficient matrices for likelihood function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

retDeriv = nargout>1;
nPout = numel(posPout);
nPer = size(G, 2);
ixy = this.Quantity.Type==TYPE(1); 
ixp = this.Quantity.Type==TYPE(4); 
ixg = this.Quantity.Type==TYPE(5); 
ny = sum(ixy);
posy = find(ixy);
ixd = this.Equation.Type==TYPE(3);
eqtn = this.Equation.Dynamic;

if isequal(alt, @all)
    nRun = length(this);
    alt = 1 : nRun;
else
    nRun = length(alt);
end

% Return matrix of deterministic trends, W, and the impact
% matrix for out-of-likelihood parameters, dW.
W = zeros(ny, nPer, nRun);
if retDeriv
    dW = zeros(ny, nPout, nPer, nRun);
    gr = this.Gradient.Dynamic(1, :);
    wrt = this.Gradient.Dynamic(2, :);
end

for r = 1 : nRun
    % Get requested parameter variant.
    xa = this.Variant{ min(end, alt(r)) }.Quantity;
    xa(1, ~ixp) = NaN;
    
    % Reset out-of-likelihood parameters to zero.
    if nPout>0
        xa(1, posPout, :) = 0;
    end
    xa = permute(xa, [2, 1]);
    xa = repmat(xa, 1, nPer);
    
    for iEqn = find(ixd)
        % This equation gives dtrend for measurement variable ptr.
        ptr = this.Pairing.Dtrend(iEqn);
        % Evaluate deterministic trend with out-of-lik parameters set zero.
        xa(ixg, :) = G(:, :, min(end, alt(r)));
        W(posy==ptr, :, r) = eqtn{iEqn}(xa, ':');
        if retDeriv ...
                && ~isempty(posPout) && ~isempty(wrt{iEqn})...
                && ~isempty(intersect(posPout, wrt{iEqn}))
            for j = posPout(:).'
                ix = wrt{iEqn}==j;
                if any(ix)
                    dW(posy==ptr, posPout==j, :, r) = gr{iEqn}{ix}(xa, ':');
                end
            end
        end
    end
end

end
