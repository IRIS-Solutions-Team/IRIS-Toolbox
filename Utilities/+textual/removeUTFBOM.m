% Remove UTF-8 and UTF-16 bytes order mark from the beginnings of
% CSV files created sometimes by MS Excel for Mac

function file = removeUTFBOM(file)

isStringInput = isstring(file);
if isStringInput
    file = char(file); 
end

UTF8 = char([239, 187, 191]);
if strncmp(file, UTF8, numel(UTF8))
    file = file(length(UTF8)+1:end);
end

UTF16 = char(65279);
if strncmp(file, UTF16, 1)
    file = file(2:end);
end

if isStringInput
    file = string(file);
end

end%

