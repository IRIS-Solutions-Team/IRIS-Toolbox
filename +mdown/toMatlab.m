function outputFile = toMatlab(fileName)

[filePath, fileTitle, fileExt ] = fileparts(string(fileName));
input = string(fileread(fileName));

output = mdown.backend.toMatlab(input);

outputFile = fullfile(filePath, fileTitle+".m");
textual.write(output, outputFile);

end%
