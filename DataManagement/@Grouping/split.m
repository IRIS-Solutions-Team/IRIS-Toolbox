
function this = splitgroup(this, varargin)

groupName = varargin;

pp = inputParser( );
pp.addRequired('g', @(x) isa(x, 'Grouping'));
pp.addRequired('groupName', @iscellstr);
pp.parse(this, groupName);

%--------------------------------------------------------------------------

for iGroup = 1 : numel(groupName)
    ix = strcmpi(this.GroupNames, groupName{iGroup}) ;
    if any(ix)
        % Group exists, split
        split = this.GroupContents{ix} ;
        this = rmgroup(this, groupName{iGroup}) ;
    elseif strcmpi(this.OTHER_NAME, groupName{iGroup})
        % Split apart 'Other' group
        split = this.OtherContents ;
    else
        % Group does not exist, cannot split
        throw( ...
            exception.Base('Grouping:NotExistCannotSplit', 'error'), ...
            groupName{iGroup} ...
            );
    end
    
    for iSplit = find(split(:).')
        this = addgroup(this, this.Label{iSplit}, this.List{iSplit}) ;
    end
end

end


