function [W, dW] = evalTrendEquations(this, posOutlikParams, inputData, variantsRequested)

% >=R2019b
%{
arguments
    this
    posOutlikParams (1, :) double
    inputData (:, :, :) double
    variantsRequested (1, :) double
end
%}
% >=R2019b


numPeriods = size(inputData, 2);
numPages = size(inputData, 3);
numParamsOut = numel(posOutlikParams);
inxY = this.Quantity.Type==1;
numY = nnz(inxY);
inxTrendEquations = this.Equation.Type==3;
returnDerivatives = nargout>=1;
numRuns = max(numPages, numel(variantsRequested));

W = zeros(numY, numPeriods, numRuns);
if returnDerivatives
    dW = zeros(numY, numParamsOut, numPeriods, numRuns);
end

if ~any(inxTrendEquations)
    return
end

numQuantities = numel(this.Quantity.Name);
inxP = this.Quantity.Type==4;
inxG = this.Quantity.Type==5;
posY = find(inxY);
eqtn = this.Equation.Dynamic;

% Retrieve data for exogenous variables
exogenousData = here_prepareExogenousData( );

% Return matrix of deterministic trends, W, and the impact
% matrix for out-of-likelihood parameters, dW.
if returnDerivatives
    gr = this.Gradient.Dynamic(1, :);
    wrt = this.Gradient.Dynamic(2, :);
end

posTrendEquations = find(inxTrendEquations);
for r = 1 : numRuns
    % Get requested parameter variant.
    v = variantsRequested(min(r, end));
    p = min(r, numPages);
    xa = this.Variant.Values(:, :, v);
    xa(1, ~inxP) = NaN;

    % Reset out-of-likelihood parameters to zero.
    if numParamsOut>0
        xa(1, posOutlikParams, :) = 0;
    end
    xa = permute(xa, [2, 1]);
    xa = repmat(xa, 1, numPeriods);
    xa(inxG, :) = exogenousData(:, :, p);

    for iEqn = posTrendEquations
        % This equation gives measurement trend for measurement variable ptr
        ptr = this.Pairing.Dtrends(iEqn);

        % Evaluate deterministic trend with out-of-lik parameters set zero
        W(posY==ptr, :, r) = eqtn{iEqn}(xa, ':');

        if returnDerivatives ...
           && ~isempty(posOutlikParams) && ~isempty(wrt{iEqn})...
           && ~isempty(intersect(posOutlikParams, wrt{iEqn}))
            for j = posOutlikParams(:).'
                ix = wrt{iEqn}==j;
                if any(ix)
                    dW(posY==ptr, posOutlikParams==j, :, r) = gr{iEqn}{ix}(xa, ':');
                end
            end
        end
    end
end

return


    function exogenousData = here_prepareExogenousData( )
        %(
        numRowsInputData = size(inputData, 1);
        if numRowsInputData==nnz(inxG)
            % Input data is exogenous variables only
            exogenousData = inputData;
        elseif numRowsInputData==numQuantities
            % Input data is a data matrix for all model variables
            exogenousData = inputData(inxG, :, :);
        end
        %)
    end%
end%

