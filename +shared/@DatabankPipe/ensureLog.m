function array = ensureLog(~, dbInfo, array)

inxNeedsLog = ...
    ismember(dbInfo.AllNames, dbInfo.LogNames) ...
    & ~ismember(dbInfo.AllNames, dbInfo.NamesWithLogInputData);

array(inxNeedsLog, :, :) = log(array(inxNeedsLog, :, :));

end%

