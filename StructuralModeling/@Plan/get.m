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
% __`response`__ [ * ] -
% Response to the `query` about the `plan`.
%
%
% ## Valid Queries ##
%
% __`AnticipationStatus`__ returns [ struct | Dictionary ] -
% Databank with the anticipation status (`true` or `false`) for each
% endogenous and exogenous quantity.
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
% __`NamesOfAnticipated`__ returns [ cellstr ] -
% List of names of exogenous quantities (shocks in Model objects) whose
% anticipation status is `true`.
%
% __`NamesOfUnanticipated`__ returns [ cellstr ] -
% List of names of exogenous quantities (shocks in Model objects) whose
% anticipation status is `false`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function response = get(this, query)

if validate.anyString(query, 'Exogenized', 'OnlyExogenized', 'ExogenizedOnly')
    names = this.NamesOfEndogenous;
    inx = this.IdAnticipatedExogenized~=0 | this.IdUnanticipatedExogenized~=0;
    response = here_getSwapped(names, inx);

elseif validate.anyString(query, 'Endogenized', 'OnlyEndogenized', 'EndogenizedOnly')
    names = this.NamesOfExogenous;
    inx = this.IdAnticipatedEndogenized~=0 | this.IdUnanticipatedEndogenized~=0;
    response = here_getSwapped(names, inx);

elseif validate.anyString(query, 'NamesOfAnticipated', 'NamesOfUnanticipated')
    response = this.(char(query));

elseif validate.anyString(query, 'AnticipationStatus', 'Anticipate')
    response = cell2struct( ...
        num2cell([this.AnticipationStatusEndogenous; this.AnticipationStatusExogenous]) ...
        , cellstr([this.NamesOfEndogenous(:); this.NamesOfExogenous(:)]) ...
    );

elseif validate.anyString(query, 'Sigma', 'Sigmas')
    response = here_getSigmas( );

else
    thisError = { 'Plan:InvalidQuery'
                  'This is not a valid query into a Plan object: %s'};
    throw(exception.Base(thisError, 'error'));
end

return
    
    function response = here_getSwapped(names, inx)
        isOnly = contains(query, 'Only', 'IgnoreCase', true);
        template = Series(this.BaseRange, true);
        numNames = numel(names);
        response = struct( );
        for i = 1 : numNames
            ithRow = inx(i, :, :);
            if isOnly && all(ithRow(:)==0)
                continue
            end
            series__ = fill(template, permute(ithRow, [2, 3, 1]));
            response.(names{i}) = series__;
        end
    end%


    function response = here_getSigmas( )
        names = "sigma_" + this.NamesOfExogenous;
        start = this.BaseStart;
        baseRangeColumns = this.BaseRangeColumns;
        response = struct( );
        for i = 1 : numel(names)
            response.(char(names(i))) = Series( ...
                start, permute(this.SigmasExogenous(i, baseRangeColumns, :), [2, 3, 1]) ...
            );
        end
    end%
end%

