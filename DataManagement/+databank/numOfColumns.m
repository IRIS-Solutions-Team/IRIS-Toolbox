function noc = numOfColumns(inputDatabank, list)
% numOfColumns  Number of columns in TimeSubscriptable objects in databank
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if ~iscellstr(list)
    list = cellstr(list);
end

if isa(inputDatabank, 'containers.Map')
    allEntries = keys(inputDatabank);
else
    allEntries = fieldnames(inputDatabank);
end

lenOfList = numel(list);
noc = nan(1, lenOfList);
for i = 1 : lenOfList
    ithName = list{i};
    if ~any(strcmpi(ithName, allEntries))
        continue
    end
    if isa(inputDatabank, 'containers.Map')
        x = inputDatabank(ithName);
    else
        x = getfield(inputDatabank, ithName);
    end
    if ~isa(x, 'TimeSubscriptable')
        continue
    end
    sizeOfData = size(x);
    noc(i) = prod(sizeOfData(2:end));
end

end%

