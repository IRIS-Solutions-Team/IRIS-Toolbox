function [W, dW] = evalDtrends(this, posParamsOut, exogenousData, variantsRequested)
% evalDtrends  Evaluate dtrend coefficient matrices for likelihood function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

returnDerivatives = nargout>1;
numParamsOut = numel(posParamsOut);
numPeriods = size(exogenousData, 2);
ixy = this.Quantity.Type==TYPE(1); 
ixp = this.Quantity.Type==TYPE(4); 
ixg = this.Quantity.Type==TYPE(5); 
ny = sum(ixy);
posy = find(ixy);
ixd = this.Equation.Type==TYPE(3);
eqtn = this.Equation.Dynamic;

if nargin<4 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : length(this);
end
numVariantsRequested = length(variantsRequested);

% Return matrix of deterministic trends, W, and the impact
% matrix for out-of-likelihood parameters, dW.
W = zeros(ny, numPeriods, numVariantsRequested);
if returnDerivatives
    dW = zeros(ny, numParamsOut, numPeriods, numVariantsRequested);
    gr = this.Gradient.Dynamic(1, :);
    wrt = this.Gradient.Dynamic(2, :);
end

for r = 1 : numVariantsRequested
    % Get requested parameter variant.
    v = variantsRequested(r);
    xa = this.Variant.Values(:, :, min(v, end));
    xa(1, ~ixp) = NaN;
    
    % Reset out-of-likelihood parameters to zero.
    if numParamsOut>0
        xa(1, posParamsOut, :) = 0;
    end
    xa = permute(xa, [2, 1]);
    xa = repmat(xa, 1, numPeriods);
    
    for iEqn = find(ixd)
        % This equation gives dtrend for measurement variable ptr.
        ptr = this.Pairing.Dtrend(iEqn);
        % Evaluate deterministic trend with out-of-lik parameters set zero.
        xa(ixg, :) = exogenousData(:, :, min(v, end));
        W(posy==ptr, :, r) = eqtn{iEqn}(xa, ':');
        if returnDerivatives ...
                && ~isempty(posParamsOut) && ~isempty(wrt{iEqn})...
                && ~isempty(intersect(posParamsOut, wrt{iEqn}))
            for j = posParamsOut(:).'
                ix = wrt{iEqn}==j;
                if any(ix)
                    dW(posy==ptr, posParamsOut==j, :, r) = gr{iEqn}{ix}(xa, ':');
                end
            end
        end
    end
end

end
