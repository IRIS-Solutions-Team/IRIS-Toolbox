% lookupNames  Look up names based on regular expression
%
% __Syntax__
%
%     matches = lookupNames(model, query)
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
% * `matches` [ cellstr ] - Names from the model object matching the
% regular expression or expressions specified in `query`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function matches = lookupNames(this, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.lookup');
    addRequired(parser, 'model', @(x) isa(x, 'model'));
    addRequired(parser, 'query', @validateQuery);
end
parse(parser, this, varargin);

%--------------------------------------------------------------------------

numQueries = numel(varargin);
matches = cell.empty(1, 0);
if numQueries==0
    return
end

% Combine the results of all queries into one
ell = lookup(this.Quantity, varargin{1});
for i = 2 : numQueries
    ithEll = lookup(this.Quantity, varargin{i});
    ell.IxName = ell.IxName | ithEll.IxName;
    ell.IxStdCorr = ell.IxStdCorr | ithEll.IxStdCorr;
end

if any(ell.IxName)
    % Add names of variables, shocks, parameters
    matches = [
        matches, ...
        this.Quantity.Name(ell.IxName)
    ];
end

if any(ell.IxStdCorr)
    inxShocks = this.Quantity.Type==31 | this.Quantity.Type==32;
    numShocks = nnz(inxShocks);
    if any(ell.IxStdCorr(1:numShocks))
        % Add names of std deviations
        matches = [
            matches, ...
            getStdNames(this.Quantity, ell.IxStdCorr(1:numShocks))
        ];
    end
    if any(ell.IxStdCorr(numShocks+1:end))
        % Add names of correlations
        matches = [ 
            matches, ...
            getCorrNames(this.Quantity, ell.IxStdCorr(numShocks+1:end))
        ];
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

