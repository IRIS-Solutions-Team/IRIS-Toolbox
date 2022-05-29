function New = copy(This)
% copy  Create a copy of a report object.
%
% Help provided in +report/copy.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

thisClass = class(This);
New = feval(thisClass);
New.children = cell(size(This.children));
for i = 1 : length(This.children)
    New.children{i} = copy(This.children{i});
end
mc = metaclass(This);
for i = 1 : length(mc.Properties)
    name = mc.Properties{i}.Name;
    if ~all(strcmpi(name,'children')) ...
            && ~mc.Properties{i}.Dependent ...
            && ~mc.Properties{i}.Constant
        New.(name) = This.(name);
    end
end

end
