function this = rmgroup(this, varargin)
% rmgroup  Remove group from grouping object.
%
% Syntax
% =======
%
%     g = rmgroup(g, groupName1, groupName2, ...)
%
%
% Input arguments
% ================
%
% * `g` [ grouping ] - Grouping object.
%
% * `groupName1`, `groupName2`, ... [ char ] - Names of groups that will be
% removed.
%
%
% Output arguments
% =================
%
% * `g` [ grouping ] - Grouping object.
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
pp.addRequired('G', @(x) isa(x, 'grouping'));
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


