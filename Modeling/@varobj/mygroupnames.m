function This = mygroupnames(This,GroupNames)
% mygroupnames  [Not a public function] Assign group names in panel VAR.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------
 
if ischar(GroupNames)
    GroupNames = regexp(GroupNames,'\w+','match');
end

if iscellstr(GroupNames)
    GroupNames = GroupNames(:).';
    nonUnique = parser.getMultiple(GroupNames);
    if ~isempty(nonUnique)
        utils.error(class(This), ...
            'Group names must be unique: ''%s''.', ...
            nonUnique{:});
    end
    This.GroupNames = GroupNames;
else
    utils.error(class(This), ...
        'Invalid group names.');
end

end