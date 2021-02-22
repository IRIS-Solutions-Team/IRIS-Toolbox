function this = addgroup(this, groupName, lsContents)
% addgroup  Add measurement variable group or shock group to grouping object.
%
% Syntax
% =======
%
%     g = addgroup(g, groupName, groupContents)
%
%
% Input arguments
% ================
%
% * `G` [ grouping ] - Grouping object.
%
% * `groupName` [ char ] - New group name.
%
% * `groupContents` [ char | cell | `@all` ] - Names of shocks or
% measurement variables to be included in the new group; `GroupContents`
% can also be regular expressions; `@all` means the group will contain all
% shocks or measurement variables not included in any existing group.
%
%
% Output arguments
% =================
%
% * `G` [ grouping ] - Grouping object with the new group.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('g', @(x) isa(x, 'grouping'));
pp.addRequired('groupName', @(x) ~isempty(x) && ischar(x));
pp.addRequired('groupContents', @(x) ~isempty(x) ...
    && (iscell(x) || ischar(x)) || isequal(x, Inf) );
pp.parse(this, groupName, lsContents);

if ischar(lsContents)
    lsContents = regexp(lsContents, '[^ ,;]+', 'match');
end

%--------------------------------------------------------------------------

nList = length(this.List);
ixValid = true(size(lsContents));
if isequal(lsContents, Inf) || isequal(lsContents, @all)
    groupContents = this.OtherContents;
    if isempty(groupContents)
        groupContents = true(nList, 1);
    end
else
    groupContents = false(1, nList);
    for i = 1 : length(lsContents)
        ind = textfun.matchindex(this.List, lsContents{i});
        ixValid(i) = any(ind);
        groupContents = groupContents | ind;
    end
    groupContents = groupContents.';
end

chkName( );

ind = strcmpi(this.GroupNames, groupName);
if any(ind)
    % Group already exists, modify
    this.GroupNames{ind} = groupName;
    this.GroupContents{ind} = groupContents;
else
    % Add new group
    this.GroupNames = [this.GroupNames, groupName];
    this.GroupContents = [this.GroupContents, {groupContents}];
end

chkUnique( );

return




    function chkUnique( )
        multiple = sum(double([this.GroupContents{:}]), 2) > 1;
        if any(multiple)
            throw( ...
                exception.Base('Grouping:MultipleOccurrence', 'error'), ...
                this.Type, this.List{multiple} ...
                );
        end
    end




    function chkName( )
        if any(~ixValid)
            throw( ...
                exception.Base('Grouping:InvalidName', 'error'), ...
                this.Type, lsContents{~ixValid} ...
                );

        end
    end
end
