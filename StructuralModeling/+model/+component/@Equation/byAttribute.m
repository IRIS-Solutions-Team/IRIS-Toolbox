function list = byAttributes(this, attributes)

attributes = reshape(string(attributes), 1, []);
attributes = strip(attributes);

numQuantities = numel(this.Name);
inx = false(1, numQuantities);
for i = 1 : numQuantities
    inx(i) = any(this.Attributes{i}==attributes);
end

list = string(this.Name(inx));

end%


