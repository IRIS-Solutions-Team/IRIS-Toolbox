function [W, dW] = evalDtrends(this, posOfParamsOut, exogenousData, variantsRequested)
% evalDtrends  Evaluate dtrend coefficient matrices for likelihood function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

returnDerivatives = nargout>1;
numOfParamsOut = numel(posOfParamsOut);
numOfPeriods = size(exogenousData, 2);
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
numOfVariantsRequested = length(variantsRequested);

% Return matrix of deterministic trends, W, and the impact
% matrix for out-of-likelihood parameters, dW.
W = zeros(ny, numOfPeriods, numOfVariantsRequested);
if returnDerivatives
    dW = zeros(ny, numOfParamsOut, numOfPeriods, numOfVariantsRequested);
    gr = this.Gradient.Dynamic(1, :);
    wrt = this.Gradient.Dynamic(2, :);
end

for r = 1 : numOfVariantsRequested
    % Get requested parameter variant.
    v = variantsRequested(r);
    xa = this.Variant.Values(:, :, min(v, end));
    xa(1, ~ixp) = NaN;
    
    % Reset out-of-likelihood parameters to zero.
    if numOfParamsOut>0
        xa(1, posOfParamsOut, :) = 0;
    end
    xa = permute(xa, [2, 1]);
    xa = repmat(xa, 1, numOfPeriods);
    
    for iEqn = find(ixd)
        % This equation gives dtrend for measurement variable ptr.
        ptr = this.Pairing.Dtrend(iEqn);
        % Evaluate deterministic trend with out-of-lik parameters set zero.
        xa(ixg, :) = exogenousData(:, :, min(v, end));
        W(posy==ptr, :, r) = eqtn{iEqn}(xa, ':');
        if returnDerivatives ...
                && ~isempty(posOfParamsOut) && ~isempty(wrt{iEqn})...
                && ~isempty(intersect(posOfParamsOut, wrt{iEqn}))
            for j = posOfParamsOut(:).'
                ix = wrt{iEqn}==j;
                if any(ix)
                    dW(posy==ptr, posOfParamsOut==j, :, r) = gr{iEqn}{ix}(xa, ':');
                end
            end
        end
    end
end

end
