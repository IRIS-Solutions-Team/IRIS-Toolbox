function [W, dW] = evalTrendEquations(this, posParamsOut, inputData, variantsRequested)
% evalTrendEquations  Evaluate and differentiate trend equations for measurement variables
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

numOfPeriods = size(inputData, 2);
numOfDataSets = size(inputData, 3);
numOfParamsOut = numel(posParamsOut);
ixy = this.Quantity.Type==TYPE(1); 
ny = nnz(ixy);
inxOfTrendEquations = this.Equation.Type==TYPE(3);
if nargin<4 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : length(this);
end
numOfVariantsRequested = numel(variantsRequested);

if ~any(inxOfTrendEquations)
    W = zeros(ny, numOfPeriods, numOfDataSets);
    dW = zeros(ny, numOfParamsOut, numOfPeriods, numOfVariantsRequested);
    return
end

returnDerivatives = nargout>1;
numOfQuantities = numel(this.Quantity.Name);
ixp = this.Quantity.Type==TYPE(4); 
ixg = this.Quantity.Type==TYPE(5); 
posy = find(ixy);
eqtn = this.Equation.Dynamic;

% Retrieve data for exogenous variables
exogenousData = prepareExogenousData( );

% Return matrix of deterministic trends, W, and the impact
% matrix for out-of-likelihood parameters, dW.
W = zeros(ny, numOfPeriods, numOfVariantsRequested);
if returnDerivatives
    dW = zeros(ny, numOfParamsOut, numOfPeriods, numOfVariantsRequested);
    gr = this.Gradient.Dynamic(1, :);
    wrt = this.Gradient.Dynamic(2, :);
end

posOfTrendEquations = find(inxOfTrendEquations);
for r = 1 : numOfVariantsRequested
    % Get requested parameter variant.
    v = variantsRequested(r);
    xa = this.Variant.Values(:, :, min(v, end));
    xa(1, ~ixp) = NaN;
    
    % Reset out-of-likelihood parameters to zero.
    if numOfParamsOut>0
        xa(1, posParamsOut, :) = 0;
    end
    xa = permute(xa, [2, 1]);
    xa = repmat(xa, 1, numOfPeriods);
    
    for iEqn = posOfTrendEquations
        % This equation gives dtrend for measurement variable ptrToVariable
        ptrToVariable = this.Pairing.Dtrend(iEqn);
        % Evaluate deterministic trend with out-of-lik parameters set zero
        xa(ixg, :) = exogenousData(:, :, min(v, end));
        W(posy==ptrToVariable, :, r) = eqtn{iEqn}(xa, ':');
        if returnDerivatives ...
           && ~isempty(posParamsOut) && ~isempty(wrt{iEqn})...
           && ~isempty(intersect(posParamsOut, wrt{iEqn}))
            for j = posParamsOut(:).'
                ix = wrt{iEqn}==j;
                if any(ix)
                    dW(posy==ptrToVariable, posParamsOut==j, :, r) = gr{iEqn}{ix}(xa, ':');
                end
            end
        end
    end
end

return


    function exogenousData = prepareExogenousData( )
        rowsOfInputData = size(inputData, 1);
        if rowsOfInputData==nnz(ixg)
            % Input data is exogenous variables only
            exogenousData = inputData;
        elseif rowsOfInputData==numOfQuantities
            % Input data is a data matrix for all model variables
            exogenousData = inputData(ixg, :, :);
        end
    end%
end%

