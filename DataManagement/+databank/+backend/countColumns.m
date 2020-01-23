function noc = countColumns(inputDatabank, list)
% countColumns  Number of columns in TimeSubscriptable objects in databank
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

list = reshape(cellstr(list), 1, [ ]);

if isa(inputDatabank, 'Dictionary')
    allEntries = keys(inputDatabank);
else
    allEntries = fieldnames(inputDatabank);
end
allEntries = reshape(string(allEntries), 1, [ ]);

lenList = numel(list);
noc = nan(1, lenList);
for i = 1 : lenList
    name__ = list{i};
    if ~any(name__==allEntries)
        continue
    end
    x = inputDatabank.(name__);
    if isa(x, 'TimeSubscriptable') || isnumeric(x) || islogical(x)
        sizeData = size(x);
        noc(i) = prod(sizeData(2:end));
    end
end

end%

