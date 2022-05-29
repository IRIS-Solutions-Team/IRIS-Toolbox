function this = splitgroup(this, varargin)
% splitgroup  Split group into its components in grouping object.
%
% Syntax
% =======
%
%     g = splitgroup(g, groupName1, groupName2, ...)
%
%
% Input arguments
% ================
%
% * `g` [ grouping ] - Grouping object.
%
% * `groupName1`, `groupName2`, ... [ char ] - Group names.
%
%
% Output arguments
% =================
%
% * `G` [ grouping ] - Grouping object.
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.

groupName = varargin;

pp = inputParser( );
pp.addRequired('g', @(x) isa(x, 'grouping'));
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


