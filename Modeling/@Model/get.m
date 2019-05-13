function value = get(this, query)
% get  Query @Model object properties
% 

%--------------------------------------------------------------------------

if any(strcmpi(query, {'InitCond', 'Required'}))
    idOfInit = getIdOfInitialConditions(this);
    value = printSolutionVector(this, idOfInit);
    return
else
    value = get@model(this, query);
    return
end

THIS_ERROR = { 'Model:InvalidGetQuery'
               'This is not a valid query to %s object: %s' };
throw( exception.Base(THIS_ERROR, 'error'), ...
       class(this), query );

end%

