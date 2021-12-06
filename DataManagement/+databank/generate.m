function outputDb = generate(inputDb, valueFunc, targetNames, inputArgNames, options)

arguments
    inputDb {validate.mustBeDatabank}
    valueFunc {mustBeA(valueFunc, "function_handle")}
    targetNames {locallyValidateTargetNames}
    inputArgNames {locallyValidateInputArgNames}

    options.TargetDb {validate.databank} = inputDb
end


outputDb = options.TargetDb;

isFunc = isa(targetNames, "function_handle");
if ~isFunc
    targetNames = textual.stringify(targetNames);
end


if iscell(inputArgNames)
    inputArgNames = vertcat(inputArgNames{:});
end


for i = 1 : size(inputArgNames, 1)
    names = textual.stringify(inputArgNames(i, :));
    names = num2cell(names);
    values = cell(names);
    for j = 1 : numel(names)
        values{j} = inputDb.(names{j});
    end

    if isFunc
        newName = targetNames(names{:});
    else
        newName = targetNames(i);
    end

    outputDb.(newName) = valueFunc(values{:});
end

end%

%
% Local functions
%

function locallyValidateInputArgNames(x)
    %(
    if isstring(x) 
        return
    end
    if iscell(x) && all(cellfun(@(y) isstring(y), x)) && allEqual(cellfun(@numel, x))
        return
    end
    error("Input value must be a string array or a cell array of strings.");
    %)
end%


function locallyValidateTargetNames(x)
    %(
    if isstring(x)
        return
    end
    if isa(x, 'function_handle')
        return
    end
    error("Input value must be a string array or a function.");
    %)
end%

