
function this = add(this, groupName, lsContents)

pp = inputParser( );
pp.addRequired('g', @(x) isa(x, 'Grouping'));
pp.addRequired('groupName', @(x) (ischar(x) || isstring(x)) && strlength(x)>0);
pp.addRequired('groupContents', @(x) ~isempty(x) && (iscell(x) || ischar(x)) || isstring(x) || isequal(x, Inf) );
pp.parse(this, groupName, lsContents);

if ischar(lsContents) || isstring(lsContents)
    lsContents = cellstr(lsContents);
end

groupName = char(groupName);

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
