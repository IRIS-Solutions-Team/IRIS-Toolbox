function noc = numOfColumns(inputDatabank, list)

if isa(list, 'string')
    list = cellstr(list);
end
nList = numel(list);
noc = nan(1, nList);

for i = 1 : nList
    ithName = list{i};
    if ~isfield(inputDatabank, ithName) || ~isa(inputDatabank.(ithName), 'TimeSeriesBase')
        continue
    end
    sizeData = size(inputDatabank.(ithName));
    noc(i) = prod(sizeData(2:end));
end

end
