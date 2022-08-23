% createTemplateDbase  Create empty template database based for Quantity object
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDb = createTemplateDbase(this)

    numQuantities = numel(this);
    x = cell(1, numQuantities);
    names = reshape(cellstr(this.Name), 1, []);
    outputDb = cell2struct(x, names, 2);
    outputDb = outputDb([]);

end%
