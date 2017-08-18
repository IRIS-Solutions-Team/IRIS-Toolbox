function noc = numberOfColumns(inputDatabank, list)

nList = numel(list);
noc = nan(1, nList);

for i = 1 : nList
    name = char(list(i));
    if ~isfield(inputDatabank, name) || ~isa(inputDatabank.(name), 'TimeSeries')
        continue
    end
    sizeData = size(inputDatabank.(name));
    noc(i) = prod(sizeData(2:end));
end

end
