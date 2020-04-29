function db = batch(db, newNameTemplate, generator, varargin )
% batch  Execute batch job within databank
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank/batch');
    addRequired(pp, 'databank', @validate.databank);
    addRequired(pp, 'newNameTemplate', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    addRequired(pp, 'expression', @(x) isa(x, 'function_handle') || ischar(x) || (isa(x, 'string') && isscalar(x)));
end
parse(pp, db, newNameTemplate, generator);

%--------------------------------------------------------------------------

[ selectNames, selectTokens ] = databank.query( db, varargin{:} );
selectNames = cellstr(selectNames);

if isa(generator, 'function_handle')
    errorReport = cellfun( @(name, tokens) hereGenerateNewFieldFromFunction(name, tokens), ...
                           selectNames, selectTokens, ...
                           'UniformOutput', false );
else
    errorReport = cellfun( @(name, tokens) hereGenerateNewFieldFromExpression(name, tokens), ...
                           selectNames, selectTokens, ...
                           'UniformOutput', false );
end

ixError = ~cellfun(@isempty, errorReport);
if any(ixError)
    errorReport = errorReport(ixError);
    errorReport = [errorReport{:}];
    error( 'databank:batch', ...
           'Error when generating this new databank field: %s \n    Matlab says: %s \n', ...
           errorReport{:} );
end

return

    function errorReport = hereGenerateNewFieldFromExpression( ithName, ithTokens )
        try
            ithNewName = hereMakeSubstitution(newNameTemplate, ithName, ithTokens);
            ithExpressiong = hereMakeSubstitution(char(generator), ithName, ithTokens);
            ithNewField = databank.eval(db, ithExpressiong);
            db.(char(ithNewName)) = ithNewField; 
            errorReport = [ ];
        catch Err
            errorReport = {ithNewName, Err.message};
        end
    end%


    function errorReport = hereGenerateNewFieldFromFunction( ithName, ithTokens )
        try
            ithNewName = hereMakeSubstitution(newNameTemplate, ithName, ithTokens);
            ithInput = db.(char(ithName));
            ithNewField = feval(generator, ithInput);
            db.(char(ithNewName)) = ithNewField;
            errorReport = [ ];
        catch Err
            errorReport = {ithNewName, Err.message};
        end
    end%
end%


%
% Local Functions
%
 

function c = hereMakeSubstitution( c, ithName, ithTokens )
    numTokens = numel(ithTokens);
    c = strrep(c, '$0', ithName);
    for j = 1 : numTokens
        c = strrep(c, sprintf('$%g', j), ithTokens{j});
    end
end%

