
function outputList = compose(pattern, inputList, opt)

    REPLACE = "%";

    outputList = repmat("", size(inputList));
    for i = 1 : numel(inputList)
        outputList(i) = replace(pattern, "%", inputList(i));
    end

end%

