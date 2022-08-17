function [flag, boundsViolated, inconsistentPrior, notFound] = chkpriors(this, estimationSpecs)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/chkpriors');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('PriorStruct', @isstruct);
end
INPUT_PARSER.parse(this, estimationSpecs);

%--------------------------------------------------------------------------

% Check consistency by looping over parameters
listOfParameters = fields(estimationSpecs);
numOfParameters = numel(listOfParameters);

indexOfValidPriors = true(1, numOfParameters);
indexOfValidBounds = true(1, numOfParameters);

ell = lookup(this.Quantity, listOfParameters);
posQty = ell.PosName;
posStdCorr = ell.PosStdCorr;
ixFound = ~isnan(posQty) | ~isnan(posStdCorr);

for i = find(ixFound)
    ithName = listOfParameters{i};
    ithParam = estimationSpecs.(ithName);
    
    if isempty(ithParam)
        initVal = NaN;
    else
        initVal = ithParam{1};
    end
    
    if isequaln(initVal, NaN) || isequal(initVal, @auto)
        % Use initial condition from model object
        if ~isnan(posQty(i))
            initVal = this.Variant.Values(:, posQty(i), :);
        elseif ~isnan(posStdCorr(i))
            initVal = this.Variant.StdCorr(:, posStdCorr(i), :);
        end
    end
    
    % get prior function
    if numel(ithParam)>3 && ~isempty(ithParam{4})
        priorLogPdf = ithParam{4};
        % check prior consistency
        if isa(priorLogPdf, 'distribution.Distribution')
            priorValue = priorLogPdf.logPdf(initVal);
        elseif isa(priorLogPdf, 'function_handle')
            priorValue = priorLogPdf(initVal);
        else
            priorValue = NaN;
        end
        indexOfValidPriors(i) = isfinite(priorValue);
    end
    
    % check bounds consistency
    if numel(ithParam)<2 || isempty(ithParam{2}) || ithParam{2}<=-realmax
        lowerBound = -Inf;
    else
        lowerBound = ithParam{2};
        indexOfValidBounds(i) = initVal>=lowerBound;
    end
    
    if numel(ithParam)<3 || isempty(ithParam{3}) || ithParam{3}>=realmax
        upperBound = Inf;
    else
        upperBound = ithParam{3};
        indexOfValidBounds(i) = initVal<=upperBound;
    end
end

flag = all(indexOfValidPriors) && all(indexOfValidBounds) && all(ixFound);
inconsistentPrior = listOfParameters(~indexOfValidPriors);
boundsViolated = listOfParameters(~indexOfValidBounds);
notFound = listOfParameters(~ixFound);

end

