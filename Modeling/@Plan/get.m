function response = get(this, query)
% get  Inquire about Plan objects
%{
% ## Syntax ##
%
%     response = get(plan, query)
%
%
% ## Input Arguments ##
%
% __`plan`__ [ Plan ] -
% Plan object that will be inquired about.
%
% __`query`__ [ char | string ] -
% Query about the `plan`.
%
%
% ## Output Arguments ##
%
% __`response` [ * ] -
% Response to the `query` about the `plan`.
%
%
% ## Valid Queries ##
%
% __`Endogenized`__ returns [ struct | Dictionary ] -
% Databank with all exogenous quantities (shocks in Model objects) as time
% series with `true` or `false` indicating whether or not the quantity is
% exogenized in the respective period; the anticipation status is not
% indicated.
%
% __`EndogenizedOnly`__ returns [ struct | Dictionary ] -
% Same as `Endogenized` except that the databank includes only those
% quantities that are endogenized at least in one period.
%
% __`Exogenized`__ returns [ struct | Dictionary ] -
% Databank with all endogenous quantities (transition and measurement
% variables in Model objects) as time series with `true` or `false`
% indicating whether or not the quantity is exogenized in the respective
% period; the anticipation status is not indicated.
%
% __`ExogenizedOnly`__ returns [ struct | Dictionary ] -
% Same as `Exogenized` except that the databank includes konly those
% quantities that are exogenized at least in one period.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team


%-------------------------------------------------------------------------------

if validate.anyString(query, 'Exogenized', 'OnlyExogenized', 'ExogenizedOnly')
    names = this.NamesOfEndogenous;
    id = this.IdOfAnticipatedExogenized | this.IdOfUnanticipatedExogenized;
    response = hereGetE_ogenized(names, id);

elseif validate.anyString(query, 'Endogenized', 'OnlyEndogenized', 'EndogenizedOnly')
    names = this.NamesOfExogenous;
    id = this.IdOfAnticipatedEndogenized | this.IdOfUnanticipatedEndogenized;
    response = hereGetE_ogenized(names, id);

else
    thisError = { 'Plan:InvalidQuery'
                  'This is not a valid query into a Plan object: %s'};
    throw(exception.Base(thisError, 'error'));
end

return
    
    function response = hereGetE_ogenized(names, id)
        isOnly = contains(query, 'Only', 'IgnoreCase', true);
        template = Series(this.BaseRange, true);
        numNames = numel(names);
        response = struct( );
        for i = 1 : numNames
            ithId = id(i, :, :);
            if isOnly && all(ithId(:)==0)
                continue
            end
            ithSeries = fill(template, permute(ithId, [2, 3, 1]));
            response = setfield(response, names{i}, ithSeries);
        end
    end%
end%

