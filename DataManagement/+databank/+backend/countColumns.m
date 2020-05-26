function noc = countColumns(inputDb, list)
% countColumns  Number of columns in TimeSubscriptable objects in databank
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

list = reshape(string(list), 1, [ ]);
lenList = numel(list);
noc = nan(1, lenList);
for i = 1 : lenList
    name__ = list(i);
    if isa(inputDb, 'Dictionary')
        if lookupKey(inputDb, name__)
            field__ = retrieve(inputDb, name__);
        else
            continue
        end
    else
        if isfield(inputDb, name__)
            field__ = inputDb.(name__);
        else
            continue
        end
    end
    if isa(field__, 'TimeSubscriptable') || isnumeric(field__) || islogical(field__)
        sizeData = size(field__);
        noc(i) = prod(sizeData(2:end));
    end
end

end%

