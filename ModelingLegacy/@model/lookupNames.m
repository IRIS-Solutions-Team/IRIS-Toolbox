function listOfMatches = lookupNames(this, varargin)
% lookupNames  Look up names based on regular expression
%
% __Syntax__
%
%     listOfMatches = lookupNames(model, query)
%
%
% __Input Arguments__
%
% * `model` [ Model ] - Model object whose names (variables, shocks,
% parameters) will be queried.
%
% * `query` [ cellstr | char | rexp | string ] - Regular expression (or
% expressions) that will be matched.
%
%
% __Output Arguments__
%
% * `listOfMatches` [ cellstr ] - Names from the model object matching the
% regular expression or expressions specified in `query`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.lookup');
    addRequired(parser, 'model', @(x) isa(x, 'model'));
    addRequired(parser, 'query', @validateQuery);
end
parse(parser, this, varargin);

%--------------------------------------------------------------------------

numOfQueries = numel(varargin);
listOfMatches = cell.empty(1, 0);
if numOfQueries==0
    return
end

% Combine the results of all queries into one
ell = lookup(this.Quantity, varargin{1});
for i = 2 : numOfQueries
    ithEll = lookup(this.Quantity, varargin{i});
    ell.IxName = ell.IxName | ithEll.IxName;
    ell.IxStdCorr = ell.IxStdCorr | ithEll.IxStdCorr;
end

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

end%


%
% Local Functions
%


function flag = validateQuery(input)
    if isempty(input)
        flag = true;
        return
    elseif all(cellfun(@(x) ischar(x) || isa(x, 'rexp'), input))
        flag = true;
        return
    end
    flag = false;
end%

