classdef json
    methods (Static)
        function output = read(fileName)
            output = jsondecode(fileread(fileName));
        end%

        function write(input, fileName, options)
            arguments
                input
                fileName (1, 1) string

                options.Beautify (1, 1) logical = true
            end
            textual.write(string(jsonencode(input)), fileName);
            if options.Beautify
                iris.utils.json.beautify(fileName);
            end
        end%

        function beautify(fileName)
            fileName = string(fileName);
            tempFileName = fileName + ".temp";
            [status, output] = system("jq --indent 4 . " + fileName + " > " + tempFileName);
            if exist(tempFileName, "file")
                movefile(tempFileName, fileName);
            end
        end%
    end
end

