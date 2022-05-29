function Collect = findall(This,varargin)
% findall  Find all objects of a given type within a report.
%
% Help provided in +report/findall.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

Collect = { };
for i = 1 : length(This.children)
    flag = false;
    for j = 1 : length(varargin)
        if isa(This.children{i},varargin{j})
            flag = true;
            break
        end
    end
    if flag
        Collect{end+1} = This.children{i}; %#ok<AGROW>
    end
end

end
