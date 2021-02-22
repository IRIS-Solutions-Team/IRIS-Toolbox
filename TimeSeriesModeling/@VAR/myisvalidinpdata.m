function flag = myisvalidinpdata(this, inp)
% myisvalidinpdata  Validate input data for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(inp)
    flag = true;
    return
end

if this.IsPanel
    % Panel VAR
    numGroups = this.NumGroups;
    inxGroupStruct = false(1, numGroups);
    if isstruct(inp)
        for i = 1 : numGroups
            name = this.GroupNames(i);
            inxGroupStruct(i) = isfield(inp, name) && isstruct(inp.(name));
        end
    end
    if any(~inxGroupStruct)
        utils.warning('VAR:myisvalidinpdata', ...
            'This group is missing from input database: ''%s''.', ...
            this.GroupNames(~inxGroupStruct));
    end
    flag = isstruct(inp) && all(inxGroupStruct);
else
    % Non-panel VAR.
    flag = isstruct(inp);
end

end%

