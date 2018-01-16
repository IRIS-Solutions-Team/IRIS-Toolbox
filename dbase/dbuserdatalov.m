function LOV = dbuserdatalov(D,FIELD,varargin)
% dbuserdatalov  List of values found in a specified user data field in tseries objects.
%
% Syntax
% =======
%
%     LOV = dbuserdatalov(D,FIELD)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database whose tseries objects will be searched.
%
% * `FIELD` [ char ] - Name of a userdata field whose values will be
% collected across all tseries objects.
%
% Output arguments
% =================
%
% * `LOV` [ cellstr ] - List of values found in the field `FIELD` of
% all tseries objects; only char values (text strings) are included; each
% value is included only once in `LOV`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%**************************************************************************

list = fieldnames(D).';
LOV = cell(1,0);
if strncmp(FIELD,'.',1)
    FIELD(1) = '';
end
for i = 1 : length(list)
    if ~isa(D.(list{i}),'tseries') ...
            || ~isa(userdata(D.(list{i})),'struct')
        continue
    end
    u = userdata(D.(list{i}));
    if isfield(u,FIELD) && ischar(u.(FIELD))
        LOV{end+1} = strtrim(u.(FIELD)); %#ok<AGROW>
    end
end

[ans,index] = unique(LOV,'first'); %#ok<NOANS,ASGLU>
index = sort(index);
LOV = LOV(index);

end