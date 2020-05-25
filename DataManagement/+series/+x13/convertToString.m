function output = convertToString(input)

output = reshape(string(input), 1, [ ]);
if islogical(input)
    output = replace(output, ["true", "false"], ["yes", "no"]);
end
if numel(output)>1
    output = "(" + join(string(output), " ") + ")";
end

end%

