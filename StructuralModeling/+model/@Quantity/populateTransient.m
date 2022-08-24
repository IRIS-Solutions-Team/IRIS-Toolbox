function this = createLookupTable(this)

    numQuantities = numel(this.Name);
    names = reshape(cellstr(this.Name), 1, []);
    this.LookupTable = cell2struct(num2cell(1:numQuantities), cellstr(names), 2);

end%

