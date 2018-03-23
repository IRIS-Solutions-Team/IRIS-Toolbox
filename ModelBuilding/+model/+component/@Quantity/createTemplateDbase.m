function d = createTemplateDbase(this, lsReservedName)
% createTemplateDbase  Create empty template database based for Quantity object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

nName = length(this);
nReserved = length(lsReservedName);
x = cell(1, nName+nReserved);
c = [this.Name, lsReservedName];
d = cell2struct(x, c, 2);
d = d([ ]);

end
