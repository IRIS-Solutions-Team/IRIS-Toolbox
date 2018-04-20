function listOfMatches = lookupNames(this, query)
% lookupNames  Look up names based on regular expression

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model.lookup');
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('Query', @(x) ischar(x) || isa(x, 'string') || isa(x, 'rexp'));
end
inputParser.parse(this, query);

%--------------------------------------------------------------------------

ell = lookup(this.Quantity, query);

listOfMatches = cell.empty(1, 0);

if any(ell.IxName)
    listOfMatches = [ listOfMatches, ...
                      this.Quantity.Name(ell.IxName) ];
end

if any(ell.IxStdCorr)
    TYPE = @int8;
    indexOfShocks = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
    numOfShocks = nnz(indexOfShocks);
    if any(ell.IxStdCorr(1:numOfShocks))
        listOfMatches = [ listOfMatches, ...
                          getStdName(this.Quantity, ell.IxStdCorr(1:numOfShocks)) ];
    end
    if any(ell.IxStdCorr(numOfShocks+1:end))
        listOfMatches = [ listOfMatches, ...
                          getCorrName(this.Quantity, ell.IxStdCorr(numOfShocks+1:end)) ];
    end
end

if isa(query, 'string')
    listOfMatches = string(listOfMatches);
end

end%
