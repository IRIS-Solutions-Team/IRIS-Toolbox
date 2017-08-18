function d = batch(d, newNameTemplate, generator, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('databank/batch');
    INPUT_PARSER.addRequired('Databank', @isstruct);
    INPUT_PARSER.addRequired('NewNameTemplate', @(x) ischar(x) || (isstring(x) && isscalar(x)));
    INPUT_PARSER.addRequired('Expression', @(x) isa(x, 'function_handle') || ischar(x) || (isstring(x) && isscalar(x)));
end

INPUT_PARSER.parse(d, newNameTemplate, generator);

%--------------------------------------------------------------------------

[selectNames, selectTokens] = databank.filter(d, varargin{:});

if isa(generator, 'function_handle')
    errorReport = cellfun( ...
        @(name, tokens) generateNewFieldFromFunction(name, tokens), ...
        selectNames, selectTokens, ...
        'UniformOutput', false ...
    );
else
    errorReport = cellfun( ...
        @(name, tokens) generateNewFieldFromExpression(name, tokens), ...
        selectNames, selectTokens, ...
        'UniformOutput', false ...
    );
end

ixError = ~cellfun(@isempty, errorReport);
if any(ixError)
    errorReport = errorReport(ixError);
    errorReport = [errorReport{:}];
    error( ...
        'databank:batch', ...
        'Error when generating this new databank field: %s \n    Matlab says: %s \n', ...
        errorReport{:} ...
    );
end

return


    function errorReport = generateNewFieldFromExpression(iName, iTokens)
        try
            iNewName = makeSubstitutions(newNameTemplate, iName, iTokens);
            iExpression = makeSubstitutions(char(generator), iName, iTokens);
            d.(iNewName) = databank.eval(d, iExpression);
            errorReport = [ ];
        catch Err
            errorReport = {iNewName, Err.message};
        end
    end


    function errorReport = generateNewFieldFromFunction(iName, iTokens)
        try
            iNewName = makeSubstitutions(newNameTemplate, iName, iTokens);
            d.(iNewName) = feval(generator, d.(iName));
            errorReport = [ ];
        catch Err
            keyboard
            errorReport = {iNewName, Err.message};
        end
    end
end


function c = makeSubstitutions(c, iName, iTokens)
    nTokens = numel(iTokens);
    c = strrep(c, '$0', iName);
    for j = 1 : nTokens
        c = strrep(c, sprintf('$%g', j), iTokens{j});
    end
end

