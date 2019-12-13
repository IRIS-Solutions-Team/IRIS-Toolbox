function noc = countColumns(inputDatabank, list)
% countColumns  Number of columns in TimeSubscriptable objects in databank
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

list = reshape(string(list), 1, [ ]);

if isa(inputDatabank, 'Dictionary')
    allEntries = keys(inputDatabank);
else
    allEntries = fieldnames(inputDatabank);
end
allEntries = reshape(string(allEntries), 1, [ ]);

lenList = numel(list);
noc = nan(1, lenList);
for i = 1 : lenList
    name__ = list(i);
    if ~any(name__==allEntries)
        continue
    end
    if isa(inputDatabank, 'Dictionary')
        x = retrieve(inputDatabank, name__);
    else
        x = getfield(inputDatabank, name__);
    end
    if ~isa(x, 'TimeSubscriptable') && ~isnumeric(x)
        continue
    end
    sizeData = size(x);
    noc(i) = prod(sizeData(2:end));
end

end%

