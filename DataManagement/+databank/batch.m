function db = batch(db, newNameTemplate, generator, varargin )
% batch  Execute batch job within databank
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank/batch');
    addRequired(pp, 'databank', @validate.databank);
    addRequired(pp, 'newNameTemplate', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    addRequired(pp, 'expression', @(x) isa(x, 'function_handle') || ischar(x) || (isa(x, 'string') && isscalar(x)));
end
parse(pp, db, newNameTemplate, generator);

%--------------------------------------------------------------------------

[ selectNames, selectTokens ] = databank.filter( db, varargin{:} );
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

inxError = ~cellfun(@isempty, errorReport);
if any(inxError)
    errorReport = errorReport(inxError);
    errorReport = [errorReport{:}];
    error( 'databank:batch', ...
           'Error when generating this new databank field: %s \n    Matlab says: %s \n', ...
           errorReport{:} );
end

return

    function errorReport = hereGenerateNewFieldFromExpression( ithName, ithTokens )
        try
            newName__ = locallyMakeSubstitution(newNameTemplate, ithName, ithTokens);
            expression__ = locallyMakeSubstitution(char(generator), ithName, ithTokens);
            newField__ = databank.eval(db, expression__);
            db.(char(newName__)) = newField__; 
            errorReport = [ ];
        catch Err
            errorReport = {newName__, Err.message};
        end
    end%


    function errorReport = hereGenerateNewFieldFromFunction( ithName, ithTokens )
        try
            newName__ = locallyMakeSubstitution(newNameTemplate, ithName, ithTokens);
            input__ = db.(char(ithName));
            newField__ = feval(generator, input__);
            db.(char(newName__)) = newField__;
            errorReport = [ ];
        catch Err
            errorReport = {newName__, Err.message};
        end
    end%
end%


%
% Local Functions
%
 

function c = locallyMakeSubstitution( c, ithName, ithTokens )
    numTokens = numel(ithTokens);
    c = strrep(c, '$0', ithName);
    for j = 1 : numTokens
        c = strrep(c, sprintf('$%g', j), ithTokens{j});
    end
end%

