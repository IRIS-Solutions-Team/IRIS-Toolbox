classdef json
    methods (Static)
        function output = read(fileName)
            output = jsondecode(fileread(fileName));
        end%

        function write(input, fileName, options)
            arguments
                input
                fileName (1, 1) string
                options.Beautify (1, 1) logical = false
            end
            writematrix(jsonencode(input), fileName, "fileType", "text", "quoteString", false);
            if options.Beautify
                json.beautify(fileName);
            end
        end%

        function beautify(fileName)
            fileName = string(fileName);
            tempFileName = fileName + ".temp";
            system("jq --indent 4 . " + fileName + " > " + tempFileName);
            movefile(tempFileName, fileName);
        end%
    end
end

