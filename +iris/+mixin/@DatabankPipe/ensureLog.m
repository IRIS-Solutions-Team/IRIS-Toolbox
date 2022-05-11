function array = ensureLog(~, dbInfo, array, namesInRows)

inxNeedsLog = ...
    ismember(namesInRows, dbInfo.LogNames) ...
    & ~ismember(namesInRows, dbInfo.NamesWithLogInputData);

if any(inxNeedsLog)
    array(inxNeedsLog, :, :) = log(array(inxNeedsLog, :, :));
end

end%

