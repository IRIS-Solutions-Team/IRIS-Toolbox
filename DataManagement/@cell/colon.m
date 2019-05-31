function output = colon(condition, selectOutput)

if islogical(condition)
    if condition
        output = selectOutput{1};
        return
    else
        output = selectOutput{2};
        return
    end
elseif isnumeric(condition) && isscalar(condition) ...
       && all(condition==round(condition)) && all(condition>=1)
    output = selectOutput{condition};
    return
end

end%

