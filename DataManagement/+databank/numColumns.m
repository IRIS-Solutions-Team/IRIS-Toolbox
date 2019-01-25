function noc = numColumns(inputDatabank, list)
% numColumns  Number of columns in TimeSubscriptable objects in databank
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~iscellstr(list)
    list = cellstr(list);
end

numList = numel(list);
noc = nan(1, numList);
for i = 1 : numList
    ithName = list{i};
    if ~isfield(inputDatabank, ithName) || ~isa(inputDatabank.(ithName), 'TimeSubscriptable')
        continue
    end
    sizeData = size(inputDatabank.(ithName));
    noc(i) = prod(sizeData(2:end));
end

end
