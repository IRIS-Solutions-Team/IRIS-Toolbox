function this = createLookupTable(this)

numQuantities = numel(this.Name);
this.LookupTable = cell2struct(num2cell(1:numQuantities), reshape(this.Name, 1, []), 2);

end%

