function listOfMatches = lookupNames(this, query)
% lookupNames  Look up names based on regular expression
%
% __Syntax__
%
%     listOfMatches = lookupNames(Model, Query)
%
%
% __Input Arguments__
%
% * `Model` [ model ] - Model object whose names (variables, shocks,
% parameters) will be queried.
%
% * `Query` [ cellstr | char | rexp | string ] - Regular expression (or
% expressions) that will be matched.
%
%
% __Output Arguments__
%
% * `ListOfMatches` [ cellstr ] - Names from the model object matching the
% regular expression or expressions specified in `Query`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model.lookup');
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('Query', @(x) ischar(x) || isa(x, 'string') || isa(x, 'rexp') || iscellstr(x));
end
inputParser.parse(this, query);

%--------------------------------------------------------------------------

query = cellstr(query);
numOfQueries = numel(query);

% Combine the results of all queries into one
ell = lookup(this.Quantity, query{1});
for i = 2 : numOfQueries
    ithEll = lookup(this.Quantity, query{i});
    ell.IxName = ell.IxName | ithEll.IxName;
    ell.IxStdCorr = ell.IxStdCorr | ithEll.IxStdCorr;
end

listOfMatches = cell.empty(1, 0);

if any(ell.IxName)
    % Add names of variables, shocks, parameters
    listOfMatches = [ listOfMatches, ...
                      this.Quantity.Name(ell.IxName) ];
end

if any(ell.IxStdCorr)
    TYPE = @int8;
    indexOfShocks = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
    numOfShocks = nnz(indexOfShocks);
    if any(ell.IxStdCorr(1:numOfShocks))
        % Add names of std deviations
        listOfMatches = [ listOfMatches, ...
                          getStdNames(this.Quantity, ell.IxStdCorr(1:numOfShocks)) ];
    end
    if any(ell.IxStdCorr(numOfShocks+1:end))
        % Add names of correlations
        listOfMatches = [ listOfMatches, ...
                          getCorrNames(this.Quantity, ell.IxStdCorr(numOfShocks+1:end)) ];
    end
end

if isa(query, 'string')
    listOfMatches = string(listOfMatches);
end

end%
