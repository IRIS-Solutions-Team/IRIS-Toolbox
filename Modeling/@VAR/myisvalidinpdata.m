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

if ispanel(this)
    % Panel VAR.
    isStruct = isstruct(inp);
    nGrp = length(this.GroupNames);
    isGrpStruct = false(1,nGrp);
    if isStruct
        for iGrp = 1 : nGrp
            name = this.GroupNames{iGrp};
            isGrpStruct(iGrp) = isfield(inp,name) && isstruct(inp.(name));
        end
    end
    if any(~isGrpStruct)
        utils.warning('VAR:myisvalidinpdata', ...
            'This group is missing from input database: ''%s''.', ...
            this.GroupNames{~isGrpStruct});
    end
    flag = isStruct && all(isGrpStruct);
else
    % Non-panel VAR.
    flag = isstruct(inp);
end

end