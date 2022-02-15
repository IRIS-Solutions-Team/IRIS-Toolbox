function [outputStrings, snippetNames, callerFileName] = readSnippet(snippetNames)

OPEN_SNIPPET = ">>>";
CLOSE_SNIPPET = "<<<";

stack = dbstack("-completenames");
callerFileName = stack(3).file;
callerCode = string(fileread(callerFileName));

snippetNames = reshape(strip(snippetNames), 1, []);
outputStrings = string.empty(1, 0);
for n = snippetNames
    open = n + OPEN_SNIPPET;
    close =  CLOSE_SNIPPET + n;
    snippet = extractBetween(callerCode, "% " + open, "% " + close);
    snippet = regexprep(snippet, "^%", "", "lineAnchors");
    if isempty(snippet)
        snippet = extractBetween(callerCode, open, close);
    end
    if ~isscalar(snippet)
        hereThrowError();
    end
    outputStrings(end+1) = string(snippet);
end

return

    function hereThrowError()
        %(
        if isempty(snippet)
            exception.error([
                "Model:NoSnippetFound"
                "No snippet of code named %s found in %s"
            ], snippetNames, callerFileName);
        else
            exception.error([
                "Model:NoSnippetFound"
                "Multiple snippets of code named %s found in %s"
            ], snippetNames, callerFileName);
        end
        %)
    end%
end%

