
function this = rmgroup(this, varargin)

groupName = varargin;

pp = inputParser( );
pp.addRequired('G', @(x) isa(x, 'Grouping'));
pp.addRequired('GroupName', @iscellstr);
pp.parse(this, groupName);

%--------------------------------------------------------------------------

nGroup = length(groupName);
ixValid = true(1, nGroup);
for iGroup = 1:nGroup
    ix = strcmpi(this.GroupNames, groupName{iGroup}) ;
    if any(ix)
        % Group exists, remove
        this.GroupNames(ix) = [ ] ;
        this.GroupContents(ix) = [ ] ;
    elseif strcmpi(this.OTHER_NAME, groupName{iGroup})
        throw( ...
            exception.Base('Grouping:CannotRemoveGroup', 'error'), ...
            this.OTHER_NAME ...
            );
    else
        ixValid(iGroup) = false ;
    end
end

if any(~ixValid)
    throw( ...
        exception.Base('Grouping:NotExistCannotRemove', 'error'), ...
        groupName{~ixValid} ...
        );
end

end


