function d = createTemplateDbase(this)
% createTemplateDbase  Create empty template database based for Quantity object
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

numOfQuantities = length(this);
x = cell(1, numOfQuantities);
c = this.Name;
d = cell2struct(x, c, 2);
d = d([ ]);

end%
